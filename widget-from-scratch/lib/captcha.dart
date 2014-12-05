library captcha;

import 'dart:html';
import 'dart:async';

/// Provide a function [f] for a callback when the captcha is correctly answered
void captcha(DivElement e, Function f) {
  new _CaptchaElement(e, f);
}

class _CaptchaElement {
  DivElement _el;
  Function _callback;
  bool _calledBack;
  List numbers;
  _NumberSlot numSlot;

  _CaptchaElement(this._el, this._callback)
    : numSlot = new _NumberSlot(),
      numbers = new List(),
      _calledBack = false {
    for (var i = 1; i <= 10; i++) {
      numbers.add(new _NumberElement(i, _el, numSlot, this));
    }
    numbers.shuffle();
    _el.classes.add('captcha-box');

    _el.appendHtml("<p>Drag and drop numbers into the corresponding "
                   "slot to form a valid equation</p>");
    _el.children.add(numSlot.container);

    var numberContainer = new DivElement()
      ..children.addAll(numbers.map((e) => e.numberElement));
    numberContainer.classes.add('number-container');
    _el.children.add(numberContainer);
  }

  void validate() {
    if ([numSlot.left, numSlot.right, numSlot.sum].every((Element e) => e.children.length == 1)) {
      var left = int.parse(numSlot.left.text);
      var right = int.parse(numSlot.right.text);
      var sum = int.parse(numSlot.sum.text);
      if (left + right == sum) {
        numSlot.sum.classes
          ..remove('failure')
          ..add('success');
        numbers.forEach((num) {
          num.cancelAllSubscriptions();
          num.numberElement.classes.add('number-success');
        });
        if (!_calledBack) {
          // Debouncing - even though we cancel all the stream
          // subscriptions, the callback gets called more than once
          // occasionally.
          _calledBack = true;
          _callback();
        }
      } else {
        numSlot.sum.classes.add('failure');
      }
    }
  }
}

class _NumberElement {
  static const mousePointerOffset = 17;
  ParagraphElement numberElement;
  DivElement _containerElement;
  _NumberSlot _numSlot;
  _CaptchaElement _captchaElement;
  int _number;
  StreamSubscription _mouseMoveSub, _mouseLeaveSub, _mouseUpSub,
                     _mouseOutSub, _mouseDownSub;
  _NumberElement(this._number, this._containerElement, this._numSlot, this._captchaElement)
    : numberElement = new ParagraphElement() {
    numberElement.appendText(_number.toString());
    numberElement.classes.add('number-element');
    _mouseDownSub = numberElement.onMouseDown.listen(_onDragStart);
  }

  void cancelAllSubscriptions() {
    [_mouseMoveSub, _mouseLeaveSub, _mouseUpSub,
     _mouseOutSub, _mouseDownSub].forEach((sub) {
      if (sub != null) sub.cancel();
    });
  }

  void _onDragStart(MouseEvent event) {
    event.preventDefault();
    event.stopPropagation();
    Element target = event.target;
    _containerElement.children.add(target);
    target.classes.add('moving');
    target.style
      ..left = "${event.client.x - _containerElement.getBoundingClientRect().left - mousePointerOffset}px"
      ..top = "${event.client.y - _containerElement.getBoundingClientRect().top - mousePointerOffset}px";

    _mouseMoveSub = target.onMouseMove.listen(_onMouseMove);
    _mouseLeaveSub = target.onMouseLeave.listen(_onMouseMove);
    _mouseUpSub = target.onMouseUp.listen(_onDragEnd);
    _mouseOutSub = target.onMouseOut.listen(_onDragEnd);
  }

  void _onMouseMove(MouseEvent event) {
    Element target = event.target;
    var left = target.style.left;
    var top = target.style.top;
    target.style
      ..left = "${event.client.x - _containerElement.getBoundingClientRect().left - mousePointerOffset}px"
      ..top = "${event.client.y - _containerElement.getBoundingClientRect().top - mousePointerOffset}px";
    var captchaRect = _captchaElement._el.getBoundingClientRect();
    var targetRect = target.getBoundingClientRect();
    if (!captchaRect.containsRectangle(targetRect)) {
      if (targetRect.top > captchaRect.top
       || targetRect.bottom < captchaRect.bottom) {
        target.style.top = top;
      }
      if (targetRect.right > captchaRect.right
       || targetRect.left < captchaRect.left) {
        target.style.left = left;
      }
    }

  }

  void _onDragEnd(MouseEvent event) {
    event.preventDefault();
    event.stopPropagation();
    Element target = event.target;

    if (_mouseMoveSub != null) _mouseMoveSub.cancel();
    if (_mouseLeaveSub != null) _mouseLeaveSub.cancel();

    bool elementsIntersect (Element e1, Element e2) =>
        e1.getBoundingClientRect().intersects(e2.getBoundingClientRect());
    
    for (Element numSlotElement in [_numSlot.left, _numSlot.right, _numSlot.sum]) {
      if (elementsIntersect(target, numSlotElement)) {
        if (numSlotElement.children.length > 0) {
          for (Element e in numSlotElement.children) {
            _containerElement.children.add(e);
            e.classes.remove('in-slot');
          } // Clear the number slot
        }
        target.classes
          ..remove('moving')
          ..add('in-slot');
        numSlotElement.children.add(target);
        target.style
          ..left = null
          ..top = null;
        _captchaElement.validate();
        return;
      }
    }
  }
}

class _NumberSlot {
  DivElement container, left, right, sum;
  ParagraphElement _operator, _equals;
  _NumberSlot()
    : container = new DivElement(),
      left = new DivElement(),
      _operator = new ParagraphElement(),
      right = new DivElement(),
      _equals = new ParagraphElement(),
      sum = new DivElement() {
    [left, right, sum].forEach((e) => e.classes.add('number-box'));
    [_operator, _equals].forEach((e) => e.classes.add('symbol'));
    _operator.text = '+';
    _equals.text = '=';
    container.classes.add('number-slot-container');
    container.children.addAll([left, _operator, right, _equals, sum]);
  }
}
