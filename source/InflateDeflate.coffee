Type = require('type-of-is')

module.exports = (args = {})->
  # object mapping from model names to constructors
  models = args.models || {}

  # attribute name used for serializing a model's type with its
  # data via deflate
  model_key = args.model_key || '$model'

  # inflate
  # --------
  # Inflate the passed json object by converting plain json objects
  # into instances of their associated model.
  #
  # **obj** : object to inflate
  inflate = (obj)=>
    unless models
      return obj

    switch Type(obj)
      # map over arrays
      when Array
        obj.map(inflate)

      # traverse object and inflate its values
      when Object
        res = {}

        Model = null

        # if there is a @model_key attribute present in the json,
        # use it to lookup the associated model
        if (model_key of obj)
          model_name = obj[model_key]
          delete obj[model_key]

          Model = if (model_name of models)
            models[model_name]
          else
            throw new Error("Can't find Model for #{model_name}")
            null

        for k,v of obj
          res[k] = inflate(v)

        if Model
          res = new Model(res)

        res

      # return everything else as is
      else
        obj

  # deflate
  # -------
  # Deflate the passed object so that it can be passed over the
  # wire as json and inflated on the other end into models
  #
  # **obj** : object to deflate
  deflate = (obj)=>
    switch Type(obj)
      when Array
        obj.map(deflate)

      when Object
        res = {}
        for k,v of obj
          res[k] = deflate(v)
        res

      else
        if (obj and obj.deflate and Type(obj.deflate, Function))
          obj.deflate(
            model_key : model_key
          )
        else
          obj


  {
    inflate : inflate
    deflate : deflate
  }
