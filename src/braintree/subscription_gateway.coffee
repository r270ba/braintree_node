{Gateway} = require('./gateway')
{Subscription} = require('./subscription')
{SubscriptionSearch} = require('./subscription_search')
{TransactionGateway} = require('./transaction_gateway')
exceptions = require('./exceptions')

class SubscriptionGateway extends Gateway
  constructor: (@gateway) ->

  create: (attributes, callback) ->
    @gateway.http.post('/subscriptions', {subscription: attributes}, @responseHandler(callback))

  cancel: (subscriptionId, callback) ->
    @gateway.http.put("/subscriptions/#{subscriptionId}/cancel", null, @responseHandler(callback))

  find: (subscriptionId, callback) ->
    if(subscriptionId.trim() == '')
      callback(exceptions.NotFoundError("Not Found"), null)
    else
      @gateway.http.get "/subscriptions/#{subscriptionId}", (err, response) ->
        if err
          callback(err, null)
        else
          callback(null, new Subscription(response.subscription))

  responseHandler: (callback) ->
    @createResponseHandler("subscription", Subscription, callback)

  retryCharge: (subscriptionId, amount..., callback) ->
    new TransactionGateway(@gateway).sale
      amount: amount[0],
      subscriptionId: subscriptionId
    , callback

  search: (fn, callback) ->
    search = new SubscriptionSearch()
    fn(search)
    @createSearchResponse("/subscriptions/advanced_search_ids", search, @pagingFunctionGenerator(search), callback)

  update: (subscriptionId, attributes, callback) ->
    @gateway.http.put("/subscriptions/#{subscriptionId}", {subscription: attributes}, @responseHandler(callback))

  pagingFunctionGenerator: (search) ->
    super search, 'subscriptions', Subscription, (response) -> response.subscriptions.subscription

exports.SubscriptionGateway = SubscriptionGateway
