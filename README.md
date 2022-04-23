# AudioRecorder

Record audio and give it a name with the AudioRecorder app. You can play the best clips again and again. Didn't like a particular clip? Feel free to delete it.
 
All of the data handling is located in AudioRecordingRepository, which handles local read/write, and will also handle all API calls for uploading and downloading data from a future backend. This way none of the views, or viewModels need to be aware of the APIs, and that can all be added in the future, without impacting the views and viewModels.

In a production app, I would store the audioItems array in a local database, perhaps Apple's CoreData, or a SQLlite db. And if the audio files were all stored in a backend, the logic in the AudioRecordingRepository could be updated to reflect that, and would give appropriate urls to the views for playback.

