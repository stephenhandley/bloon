Assert = require('assert')
InflateDeflate = require('../build/InflateDeflate')

class Base
  constructor : (data)->
    @_data = data

  deflate : (args)->
    data = {}
    for k,v of @_data
      data[k] = v
    data[args.model_key] = @constructor.name
    data

class Barf extends Base
class Borf extends Base
class Derp extends Base


module.exports = {
  'InflateDeflate' : {
    'should properly deflate and inflate' : ()->
      data = {
        b : new Barf({x : 10})
        c : [new Borf({x : 11}), new Derp({x : 12})]
      }

      {inflate, deflate} = InflateDeflate(
        models : {
          Barf : Barf
          Borf : Borf
          Derp : Derp
        }
      )

      deflated = deflate(data)
      reinflated = inflate(deflated)

      Assert.equal(reinflated.b.x, data.b.x);
      Assert.equal(reinflated.c[0].constructor, data.c[0].constructor)
  }
}
