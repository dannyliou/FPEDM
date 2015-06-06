
IDENTIFIER = "__event_emitter"

PREFIX_LISTENERS = "__listeners_"

findOrCreateListenerTable = (event)->
  keyEvent = "#{PREFIX_LISTENERS}#{event}"

  @[keyEvent] ?= []
  return @[keyEvent]

addListener = (event, listener)->
  unless event? and listener?
    console.error "ERROR [events::addListener] invalid event:#{event} or listener:#{listener}, self:#{@}"
    return

  if @[IDENTIFIER] isnt true
    console.error "ERROR [events::addListener] self is not valid EventEmitter"
    return

  listeners = findOrCreateListenerTable.call(@, event)
  if listeners.indexOf(listener) < 0
    listeners.push listener
  else
    console.warn "[events::addListener] same listener:#{listener} for event:#{event} already exist"

  return @ # chainable


once = (event, listener)->
  unless event? and listener?
    console.error "ERROR [events::once] invalid event:#{event} or listener:#{listener}, self:#{@}"
    return

  if @[IDENTIFIER] isnt true
    console.error "ERROR [events::once] self is not valid EventEmitter"
    return

  event = "#{event}:once"
  listeners = findOrCreateListenerTable.call(@, event)
  if listeners.indexOf(listener) < 0
    listeners.push listener
  else
    console.warn "[events::once] same listener:#{listener} for event:#{event} already exist"
  return @ # chainable

removeListener = (event, listener)->

  unless event? and listener?
    console.error "ERROR [events::removeListener] invalid event:#{event} or listener:#{listener}, self:#{@}"
    return

  if @[IDENTIFIER] isnt true
    console.error "ERROR [events::removeListener] self is not valid EventEmitter"
    return

  # remove the listener from common list
  listeners = @["#{PREFIX_LISTENERS}#{event}"]
  if Array.isArray listeners
    pos = listeners.indexOf(listener)
    listeners.splice(pos, 1) if ~pos

  # remove the listener from once list
  listeners = @["#{PREFIX_LISTENERS}#{event}:once"]
  if Array.isArray listeners
    pos = listeners.indexOf(listener)
    listeners.splice(pos, 1) if ~pos

  return @

removeAllListeners = (event)->
  console.log "[events::removeAllListeners] self:#{@}, event:#{event}"

  if @[IDENTIFIER] isnt true
    console.error "ERROR [events::removeAllListeners] self is not valid EventEmitter"
    return

  if event?                                                 # when specified event
    delete @["#{PREFIX_LISTENERS}#{event}"]                  # clean up common list
    delete @["#{PREFIX_LISTENERS}#{event}:once"]             # clean up once list
  else                                                      # clean up all listeners
    listToRemove = []
    for key of @
      #console.info "[events::method] key:#{key}, index:#{key.indexOf(PREFIX_LISTENERS)}"
      listToRemove.push key if key.indexOf(PREFIX_LISTENERS) is 0

    #console.info "[events::####] listToRemove:#{listToRemove}"
    for key in listToRemove
      #console.info "[events::to delete] #{key}"
      delete @[key]

  return @

emit = (event, args...)->
  #console.log "[events::emit] self:#{self}, event:#{event}"
  unless event?
    console.error "ERROR [events::once] invalid event:#{event}"
    return

  if @[IDENTIFIER] isnt true
    console.error "ERROR [events::emit] self is not valid EventEmitter"
    return

  # call listeners
  listeners = @["#{PREFIX_LISTENERS}#{event}"]
  if Array.isArray listeners
    for listener in listeners
      listener.apply(null, args)
      #try
        #listener.apply(null, args)
      #catch err
        #console.log "[events::#{@}::emit] err:#{err}"

  # call listeners only once
  keyEvent = "#{PREFIX_LISTENERS}#{event}:once"
  listeners = @[keyEvent]
  if Array.isArray listeners
    for listener in listeners
      try
        listener.apply(null, args)
      catch err
        console.log "[events::#{@}::emit] err:#{err}"

    delete @[keyEvent]

  return @


#module.exports = exports = {
exports = {
  # 向给定的 table 注入 EventEmitter 功能，如果没有提给定的 table 那么会创建一个新 table
  # @param tbl target table
  EventEmitter: (tbl)->
    tbl or= {}

    if tbl[IDENTIFIER]?
      console.log "[events::EventEmitter] #{tbl} is already an EventEmitter"
      return tbl

    tbl[IDENTIFIER] = true
    tbl.on = addListener
    tbl.addListener = addListener
    tbl.once = once
    tbl.off = removeListener
    tbl.removeListener = removeListener
    tbl.removeAllListeners = removeAllListeners
    tbl.emit = emit
    return tbl
}

regRequire "events", exports

return exports


