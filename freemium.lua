local webhook = "https://discord.com/api/v10/webhooks/1494420941680148742/DrJ5QakV0MEwSTTFg5KMb_QJWFSF3GsDTi3J-qG7S2qWYjvpTwRDarWiqMxvkGUEfQzw"

local data = {
    ["content"] = "It works 👀",
    ["username"] = "My Bot"
}

local json = game:GetService("HttpService"):JSONEncode(data)

local req = request or http_request or syn and syn.request

if req then
    req({
        Url = webhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = json
    })
end
