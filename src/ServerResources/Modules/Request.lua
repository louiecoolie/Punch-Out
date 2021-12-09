local Request = {}

function Request.RemoteEvent(event_name, event_container)
    local event = Instance.new("RemoteEvent")
    event.Name = event_name
    event.Parent = event_container

    return event
end

function Request.RemoteFunction(event_name, event_container)
    local event = Instance.new("RemoteFunction")
    event.Name = event_name
    event.Parent = event_container

    return event
end

return Request