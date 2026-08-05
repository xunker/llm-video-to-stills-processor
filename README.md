# LLM Video-to-Stills Processor

https://github.com/xunker/llm-video-to-stills-processor

Set of scripts to convert a video into a set of still frames + audio for
processing via a Multimodel LLM/AI without native video support.

# Purpose

The majority of currently available multimodal LLMs do not have native video
support.

While projects like llama.cpp do offer built-in conversion, I've found it to be
difficult to work with and unreliable for videos langer than  a few seconds in
length.

These scripts will extract a series of still frames from a video, at regular
intervals, as well as the audio track of the file. It will appropriately scale
the still images and re-encode the audio so that the LLM can process it more
efficiently.

Also included are scrips that can send this data to a command line tool (like
llama-cli or llama-mtmd-cli), or an OpenAI-compatible HTTP endpoint.

# Preparing Data

Use both of these scripts to extract frame images and audio from a video file.

*ffmpeg* __must__ be installed and available in your current path.

## [extract_frames.sh](./extract_frames.sh)

Extracts frames from the video file at regular intervals, and scales them.

`304` is the default height because it correlates with `528 x 304` resolution
(16:9), which equates to 70 tokens with Gemma-4.

Larger heights will use more tokens, but can give better results:
- `304`: 70 tokens: fast processing, basic thumbnail or scene tag generation
- `624`: 280 tokens: general image captioning, scene description, visual QA
- `864`: 560 tokens: dense scenes, complex chart captioning, fine-grained object
  counting

When adjusting image size, consult documentation on your LLMs preprocessor. For
example, [Gemma-4 dimensions should be evenly-divisible by
48](https://huggingface.co/docs/transformers/v5.14.0/en/model_doc/gemma4#gemma4-vision-model).

Because aspect ratio is important for LLMs, the width is proportionally adjusted
to match the height.




> Usage:
>
> ./extract_frames.sh {video_filename} {arguments}
>
> argument | value | description | default
> --|--|--|--
> `video_filename` | filename | path to video file | *none*
> -i/--interval | `seconds` | Seconds between frames | `30`
> -h/--height | `pixels` | Height of output image, in pixels | `304`
> -o/--output | `directory` | Directory where the frames will be written, will be created if it does not exist  | video filename without extension
> -s/--start | `seconds` | When to extract first frame from video | `2`
> -y/--yes | none | Automatically delete existing image files in output directory | *none*
> -v/--verbose | none | Toggle verbose mode | *none*
>
> Image filenames are in the pattern `output_%03d.jpg`.

## [extract_audio.sh](./extract_audio.sh)

Extracts the audio portion of the video to a 16kHz, mono .wav file.

> Usage:
>
> ./extract_audio.sh {video_filename} {arguments}
>
> argument | value | description | default
> --|--|--|--
> `video_filename` | filename | path to video file | *none*
> -o/--output | `directory` | Directory where the audio will be written, will be created if it does not exist | video filename without extension
> -y/--yes | none | Automatically delete existing audio files in output directory | *none*
>
> Filename will be `audio.wav`.

# Sending to LLM

## [runner_llama-mtmd-cli.sh](./runner_llama-mtmd-cli.sh)

TBA

## [runner_llama-cli.sh](./runner_llama-mtmd-cli.sh)

TBA

## [runner_open-ai.sh](./runner_open-ai.sh)

TBA

# License

MIT. See [LICENSE.txt](LICENSE.txt).
