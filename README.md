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
Build a vosk server docker image with phoneme support, using the Dockerfile provided in the repository root. `Dockerfile` compiles the base dependencies required, and `Dockerfile.en` provides a working model.
```bash
docker build --tag "zenyawastaken/vosk-server-phoneme" . # Dockerfile
mv Dockerfile.en Dockerfile
docker build --tag "zenyawastaken/vosk-server-phoneme-en" . # Dockerfile.en
docker run -d -p 2700:2700 zenyawastaken/vosk-server-phoneme-en:latest
```
While the above commands will build a fully functional vosk server, we can minimise it further by removing unnecessary install layers. Copy out `zenyawastaken/vosk-server-phoneme-en:/opt` locally, before rebuilding the container as seen in [Dockerfile.min](Dockerfile.min).

### Models
The Vosk webserver accepts any model found [here](https://alphacephei.com/vosk/models). Custom models can be mounted to `/opt/vosk-model/model-en` to override the [default model used](https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip).

### Audio Conversion
Make sure the supplied audio is the same bitrate as the training data (usually 16kHz). Include the `-f` flag to output a raw PCM file (no headers, suitable for streaming) 
```bash
ffmpeg -i <input audio file> -ar 16000 -ac 1 -acodec pcm_s16le output.wav
```
### Starting the Webserver
Start the webserver using
```bash
python3 webserver/asr_server.py <path to model folder>
```
[Phoneme label & timestamp support](https://github.com/alphacep/vosk-api/pull/1377) is enabled by default. This can be toggled, along with other options, by sending a stringified 'config' JSON object to the webserver.
```json
{
  "config": {
    "phrase_list": "object",
    "sample_rate": "int",
    "model": "Model",
    "words": "bool",
    "max_alternatives": "int",
    "result_options": "string"
  }
}
```
Ensure that a valid kaldi phone mapping is present under `/<model>/graph/phones.txt`.

### Testing the Webserver
Test the webserver using
```bash
python3 webserver/test.py <path to .wav file>
```
Refer to the implementation in [test.py](websocket/test.py) to send arbitrary audio data.

### Sample Output
The webserver continuously returns JSON data.
- `partial` is returned for every phrase (re)processed
- `result` and `text` are returned after a long pause, once the `partial` data is "confirmed"

This output is obtained by setting `"words": false` in the config to avoid duplicate result entries, since we have `"result_options": "phones"` which already includes each processed word by default.
```json
{
  "partial" : ""
}
{
  "partial" : ""
}
{
  "partial" : "zero"
}
{
  "partial" : "zero one"
}
{
  "partial" : "zero one"
}
{
  "partial" : "zero one eight"
}
{
  "partial" : "zero one eight"
}
{
  "partial" : "zero one eight thorough"
}
{
  "partial" : "zero one eight thorough"
}
{
  "result" : [{
      "conf" : 1.000000,
      "end" : 6.240000,
      "phone_end" : [6.240000],
      "phone_label" : ["SIL"],
      "phone_start" : [6.000000],
      "start" : 6.000000,
      "word" : "<eps>"
    }, {
      "conf" : 1.000000,
      "end" : 6.690000,
      "phone_end" : [6.450000, 6.510000, 6.600000, 6.690000],
      "phone_label" : ["z_B", "I_I", "r_I", "oU_E"],
      "phone_start" : [6.240000, 6.450000, 6.510000, 6.600000],
      "start" : 6.240000,
      "word" : "zero"
    }, {
      "conf" : 1.000000,
      "end" : 6.690000,
      "phone_end" : [6.690000],
      "phone_label" : ["SIL"],
      "phone_start" : [6.690000],
      "start" : 6.690000,
      "word" : "<eps>"
    }, {
      "conf" : 1.000000,
      "end" : 6.900000,
      "phone_end" : [6.750000, 6.810000, 6.900000],
      "phone_label" : ["w_B", "A_I", "n_E"],
      "phone_start" : [6.690000, 6.750000, 6.810000],
      "start" : 6.690000,
      "word" : "one"
    }, {
      "conf" : 1.000000,
      "end" : 6.900000,
      "phone_end" : [6.900000],
      "phone_label" : ["SIL"],
      "phone_start" : [6.900000],
      "start" : 6.900000,
      "word" : "<eps>"
    }, {
      "conf" : 1.000000,
      "end" : 7.145847,
      "phone_end" : [7.050000, 7.140000],
      "phone_label" : ["eI_B", "t_E"],
      "phone_start" : [6.900000, 7.050000],
      "start" : 6.900000,
      "word" : "eight"
    }, {
      "conf" : 1.000000,
      "end" : 7.170000,
      "phone_end" : [7.175848],
      "phone_label" : ["SIL"],
      "phone_start" : [7.145847],
      "start" : 7.145847,
      "word" : "<eps>"
    }, {
      "conf" : 0.415157,
      "end" : 7.500000,
      "phone_end" : [7.260000, 7.380000, 7.500000],
      "phone_label" : ["T_B", "3`_I", "oU_E"],
      "phone_start" : [7.170000, 7.260000, 7.380000],
      "start" : 7.170000,
      "word" : "thoreau"
    }, {
      "conf" : 1.000000,
      "end" : 7.500000,
      "phone_end" : [7.500000],
      "phone_label" : ["SIL"],
      "phone_start" : [7.500000],
      "start" : 7.500000,
      "word" : "<eps>"
    }, {
      "conf" : 1.000000,
      "end" : 7.980000,
      "phone_end" : [7.620000, 7.740000, 7.980000],
      "phone_label" : ["T_B", "r_I", "i_E"],
      "phone_start" : [7.500000, 7.620000, 7.740000],
      "start" : 7.500000,
      "word" : "three"
    }, {
      "conf" : 1.000000,
      "end" : 8.310000,
      "phone_end" : [8.310000],
      "phone_label" : ["SIL"],
      "phone_start" : [7.980000],
      "start" : 7.980000,
      "word" : "<eps>"
    }],
  "text" : " zero one eight thoreau three"
```
