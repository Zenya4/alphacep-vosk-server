## About
This is a server for highly accurate offline speech recognition using
Kaldi and [Vosk-API](https://github.com/alphacep/vosk-api).

There are four different servers which support four major communication
protocols - MQTT, GRPC, WebRTC and Websocket

The server can be used locally to provide the speech recognition to smart
home, PBX like freeswitch or asterisk. The server can also run as a
backend for streaming speech recognition on the web, it can power
chatbots, websites and telephony.

## Documentation
For documentation and instructions see [Vosk Website](https://alphacephei.com/vosk/server)

## Usage
### Building
Build an image using the Dockerfile provided in the repository root
### Models
The Vosk webserver accepts any model found [here](https://alphacephei.com/vosk/models)

### Audio Conversion
Make sure the supplied audio is the same bitrate as the training data (usually 16kHz). Include the `-f` flag to output a raw PCM file (no headers, suitable for streaming) 
```
ffmpeg -i <input audio file> -ar 16000 -ac 1 -acodec pcm_s16le output.wav
```
### Starting the Webserver
Start the webserver using
```
python3 webserver/asr_server.py <path to model folder>
```
[Phoneme label & timestamp support](https://github.com/alphacep/vosk-api/pull/1377) is enabled by default. This can be toggled, along with other options, by sending a stringlified 'config' JSON object to the webserver.
```json
{
  "config": {
    "phrase_list": "object",
    "sample_rate": "int",
    "model": "Model",
    "show_words": "bool",
    "max_alternatives": "int",
    "result_options": "string"
  }
}
```

### Testing the Webserver
Test the webserver using
```
python3 webserver/test.py <path to .wav file>
```
Refer to the implementation in [test.py](websocket/test.py) to send arbitrary audio data.
