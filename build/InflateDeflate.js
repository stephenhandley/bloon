(function() {
  var Type;

  Type = require('type-of-is');

  module.exports = function(args) {
    var deflate, inflate, model_key, models;
    if (args == null) {
      args = {};
    }
    models = args.models || {};
    model_key = args.model_key || '$model';
    inflate = (function(_this) {
      return function(obj) {
        var Model, k, model_name, res, v;
        if (!models) {
          return obj;
        }
        switch (Type(obj)) {
          case Array:
            return obj.map(inflate);
          case Object:
            res = {};
            Model = null;
            if (model_key in obj) {
              model_name = obj[model_key];
              delete obj[model_key];
              Model = (function() {
                if (model_name in models) {
                  return models[model_name];
                } else {
                  throw new Error("Can't find Model for " + model_name);
                  return null;
                }
              })();
            }
            for (k in obj) {
              v = obj[k];
              res[k] = inflate(v);
            }
            if (Model) {
              res = new Model(res);
            }
            return res;
          default:
            return obj;
        }
      };
    })(this);
    deflate = (function(_this) {
      return function(obj) {
        var k, res, v;
        switch (Type(obj)) {
          case Array:
            return obj.map(deflate);
          case Object:
            res = {};
            for (k in obj) {
              v = obj[k];
              res[k] = deflate(v);
            }
            return res;
          default:
            if (obj && obj.deflate && Type(obj.deflate, Function)) {
              return obj.deflate({
                model_key: model_key
              });
            } else {
              return obj;
            }
        }
      };
    })(this);
    return {
      inflate: inflate,
      deflate: deflate
    };
  };

}).call(this);
