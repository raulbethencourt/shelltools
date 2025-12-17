curl --location 'https://prod-23.francecentral.logic.azure.com:443/workflows/be134a02971f4102a109a6e77deb811f/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=0WyGClE9VbIS_oXizbz3_Y5Th2ashkhfmD-XnCOF_1c' \
--header 'Content-Type: application/json' \
--data '{
  "type": "message",
  "attachments": [
    {
      "contentType": "application/vnd.microsoft.card.adaptive",
      "contentUrl": null,
      "content": {
        "type": "AdaptiveCard",
        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
        "version": "1.3",
        "body": [
          {
            "type": "TextBlock",
            "text": "Test bluenote depuis Postman",
            "wrap": true,
            "color": "Accent",
            "size": "ExtraLarge"
          }
        ]
      }
    }
  ]
}
'
