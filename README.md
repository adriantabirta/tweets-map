# tweets-map

 Please create a simple application that displays tweets as pins on a map in real time according to a search term.
 For that, you will need to use the streaming API V2 from Twitter:
 https://developer.twitter.com/en/docs/twitter-api/tweets/filtered-stream/introduction
 
 Requirements
 
 The app will consist of two views.
 
 - The first one will host two elements: one input text field and a map that will display a pin for each tweet that is being produced in real time and that contains the text input by the user. Each pin should be displayed during a customizable lifespan.
 - The second screen will be displayed when the user clicks on any of the map pins. Then, the user should navigate to a new view, where the tweet’s details are shown.
 
 Useful information
 - In order to use the Twitter API V2, you must register as developer in the “Twitter Developer Portal” https://developer.twitter.com/
 - The registration in the developer portal is mandatory for getting a “Bearer Token” which must be used as a header in the requests needed to achieve the task.
 - In order to display the pins on the map, you will need to filter the tweets received and take only the ones with geolocation information (which means containing latitude and longitude).
 - To search for common words as “I”, “me” or even “I’m” used to be good examples to retrieve enough tweets for our purposes.
 - Don’t abuse making too many requests to the API because Twitter could block your session temporarily.
 - Suggestions Use up to date technologies: Swift (or even SwiftUI), Codable, Functional Programming...
 - Show how fancy your code can get, even if this is a small sample, try to replicate how you would tackle this task in a real world project.
 - Try to include as few third party libraries as possible. Use iOS world standards whenever possible.
 - If you feel it is too much, try to show-case how you would accomplish the whole task with a few samples.
 
 Read carefully Twitter API, is not just a single request, in order to succeed in the challenge you need to perform more than one.
 
 You can send the solution in form of 1 or more files by email or you can upload it to some hosted service like Github and send me the link.
