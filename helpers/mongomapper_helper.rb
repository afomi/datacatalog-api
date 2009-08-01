# MongoMapper may take care of this in the future
#
#   :methods => :id
#     adds this:
#       "id":"2792d2074a738c2300000043"
#
#   :except => :_id
#     removes this:
#       "_id":{"data":[35,140,115,74,7,210,146,39,67,0,0,0]}
#
def jsonify(document)
  document.to_json(:methods => :id, :except => :_id)
end
