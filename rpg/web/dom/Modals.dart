part of dom;

// We want to make sure modals can't open until our dart scripts are loaded.
void initializeModals() {
  querySelector('#create-character')
      .dataset['reveal-id'] = 'create-modify-character';
  querySelector('#list-all-characters')
      .dataset['reveal-id'] = 'list-characters';
}

/// Expects [f] to take no arguments
void bindFunctionToModalClose(String modalId, Function f) {
  // Extremely ugly hack to use foundation's jQuery events on modal close.
  // Equivalent to the javascript:
  //    $(modalId).on('closed.fndtn.reveal', function() {
  //      handleCloseModal(this);
  //    });
  context.callMethod(r'$', [modalId])
         .callMethod(r'on', ['closed.fndtn.reveal', (_) => f(modalId)]);
}

void handleClearModal(String modalElement) {
  querySelector(modalElement).children.clear();
}

void reinitializeFoundation() {
  // Extremely ugly hack similar to [bindFunctionToModalClose]. When
  // dynamically adding elements to the page, Foundation needs to be told
  // about them (since it's not expecting them).
  // Equivalent to the javascript:
  //    $(document).foundation();
  //
  context.callMethod(r'$', [document]).callMethod(r'foundation');
}