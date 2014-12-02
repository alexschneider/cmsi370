var BoxesTouch = {
    /**
     * Sets up the given jQuery collection as the drawing area(s).
     */
    setDrawingArea: function (jQueryElements) {
        // Set up any pre-existing box elements for touch behavior.
        jQueryElements
            .addClass("drawing-area")

            .on('touchstart', BoxesTouch.createBox)
            .on('touchmove', BoxesTouch.resizeBox)
            .on('touchend', BoxesTouch.endCreateBox)

            // Event handler setup must be low-level because jQuery
            // doesn't relay touch-specific event properties.
            .each(function (index, element) {
                element.addEventListener("touchmove", BoxesTouch.trackDrag, false);
                element.addEventListener("touchend", BoxesTouch.endDrag, false);
            })

            .find("div.box").each(function (index, element) {
                element.addEventListener("touchstart", BoxesTouch.startMove, false);
                element.addEventListener("touchend", BoxesTouch.unhighlight, false);
            });

    },

    /**
     * Tracks a box as it is rubberbanded or moved across the drawing area.
     */
    trackDrag: function (event) {
        $.each(event.changedTouches, function (index, touch) {
            // Don't bother if we aren't tracking anything.
            if (touch.target.movingBox) {
                // Reposition the object.
                touch.target.movingBox.offset({
                    left: touch.pageX - touch.target.deltaX,
                    top: touch.pageY - touch.target.deltaY
                });

                var target      = $(touch.target),
                    position    = target.position(),
                    posTop      = position.top,
                    posLeft     = position.left,
                    posBottom   = posTop + target.height(),
                    posRight    = posLeft + target.width(),
                    parent      = target.parent();

                if (posLeft < 0 
                 || posTop < 0
                 || posRight > parent.width()
                 || posBottom > parent.height()) {
                    target.addClass("box-delete");
                } else {
                    target.removeClass("box-delete");
                }
            }
        });
        
        // Don't do any touch scrolling.
        event.preventDefault();
    },

    /**
     * Concludes a drawing or moving sequence.
     */
    endDrag: function (event) {
        $.each(event.changedTouches, function (index, touch) {
            if (touch.target.movingBox) {
                // Change state to "not-moving-anything" by clearing out
                // touch.target.movingBox.
                touch.target.movingBox = null;
                if ($(touch.target).hasClass('box-delete')) {
                    $(touch.target).remove();
                }
            }
        });
    },

    /**
     * Indicates that an element is unhighlighted.
     */
    unhighlight: function () {
        $(this).removeClass("box-highlight");
    },

    /**
     * Begins a box move sequence.
     */
    startMove: function (event) {
        $.each(event.changedTouches, function (index, touch) {
            // Highlight the element.
            $(touch.target).addClass("box-highlight");

            // Take note of the box's current (global) location.
            var jThis = $(touch.target),
                startOffset = jThis.offset();

            // Set the drawing area's state to indicate that it is
            // in the middle of a move.
            touch.target.movingBox = jThis;
            touch.target.deltaX = touch.pageX - startOffset.left;
            touch.target.deltaY = touch.pageY - startOffset.top;
        });

        // Eat up the event so that the drawing area does not
        // deal with it.
        event.stopPropagation();
    },

    createBox: function (event) {
        $.each(event.originalEvent.changedTouches, function (index, touch) {
            var newBox = $('<div></div>');
            newBox
                .addClass('box')
                .css('left', touch.pageX)
                .css('top', touch.pageY);
            newBox.appendTo(touch.target);
            touch.target.start = {element: newBox, x: touch.pageX, y: touch.pageY};
        });
    },

    resizeBox: function(event) {
        $.each(event.originalEvent.changedTouches, function (index, touch) {
            if (touch.target.start) {
                var xPos = touch.pageX - touch.target.start.x,
                    yPos = touch.pageY - touch.target.start.y;
                if (xPos > 0) {
                    touch.target.start.element.css('width', xPos);
                } else {
                    touch.target.start.element
                        .css('left', touch.pageX)
                        .css('width', -xPos);
                }

                if (yPos > 0) {
                    touch.target.start.element.css('height', yPos);
                } else {
                    touch.target.start.element
                        .css('top', touch.pageY)
                        .css('height', -yPos);
                }
            }
        });
    }, 

    endCreateBox: function(event) {
        $.each(event.originalEvent.changedTouches, function (index, touch) {
            if (touch.target.start) {
                delete touch.target.start;
                BoxesTouch.setDrawingArea($(touch.target));
            }
        });
    }
};
