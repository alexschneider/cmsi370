/* exported db */
// Diabolical interface class
// All methods are async and require two parameter callbacks (err, res)
var db = (function() { // JD: Suggestion: separate function keyword from arguments.
    'use strict';
    var diabolical = {};
    var baseURL = 'http://lmu-diabolical.appspot.com';

    // Helper methods
    var ajax = function(requestVerb, requestURI, data, callback) {
        var ajaxSettings = {
            type: requestVerb,
            url: requestURI,
            dataType: 'json',
            accept: 'application/json'
        };

        if (data !== null) {
            ajaxSettings.data = JSON.stringify(data);
        }
        $.ajax(ajaxSettings).done(function(res) {
            return callback(null, res);
        }).fail(function(err) {
            return callback(err);
        });
    };

    diabolical.getCharacter = function(charID, callback) {
        var charEndPoint = '/characters';
        var requestURI = baseURL + charEndPoint;
        if (callback) {
            requestURI += '/' + charID;
        } else if (typeof charID === 'function') {
            callback = charID;
        } else {
            throw new Error('Invalid arguments');
        }
        return ajax('GET', requestURI, null, callback);
    };
    // TODO: use JS Object to pass parameters, rather than create object from parameter
    diabolical.createOrUpdateCharacter = function(charName, charClass, charGender, charLevel, charMoney, charID, callback) {
        var createCharEndPoint = '/characters';
        var requestURI = baseURL + createCharEndPoint;
        var isUpdate = false;
        if (callback) {
            requestURI += '/' + charID;
            isUpdate = true;
        } else if (typeof charID === 'function') {
            callback = charID;
        } else {
            throw new Error('Invalid arguments');
        }
        var data = {
            name: charName,
            classType: charClass,
            gender: charGender,
            level: charLevel,
            money: charMoney
        };
        var verb = 'POST';
        if (isUpdate) {
            verb = 'PUT';
            data.id = charID;
        }
        return ajax(verb, requestURI, data, callback);
    };

    diabolical.deleteChar = function(charID, callback) {
        var deleteCharEndPoint = '/characters/' + charID;
        var requestURI = baseURL + deleteCharEndPoint;
        return ajax('DELETE', requestURI, null, callback);
    };

    diabolical.createRandomChar = function(callback) {
        var randomCharEndPoint = '/characters/spawn';
        var requestURI = baseURL + randomCharEndPoint;
        return ajax('GET', requestURI, null, callback);
    };

    diabolical.createRandomItem = function(callback) {
        var randomItemEndPoint = '/items/spawn';
        var requestURI = baseURL + randomItemEndPoint;
        return ajax('GET', requestURI, null, callback);
    };

    return diabolical;
})();
