# TODO

## `extract_frames.sh`

- Option to create output directory on CWD
- Only delete image files that match the current filename pattern (`output_%03d.jpg`)
- Allow filename pattern to be set via CLI argument
- Allow image format to be set via CLI argument
- Allow image quality level to be set via CLI argument (if applicable)
- Option to extract keyframes instead of frames at a set interval

## `extract_audio.sh`

- Option to create output directory on CWD
- Option to set output file type via CLI
- Option to set output file format via CLI
- Option to set sample rate via CLI
- Option to toggle mono conversion via CLI
- Add Verbose flag
- Option to break output into smaller, sequential files

## `runner_*.sh`
- Handle filenames that contain commas
- Handle filenames that contain spaces
- Default prompt text
- Option to pass replacement prompt via CLI
- Option to pass additional/appended prompts via CLI (allow multiple)
- Option to specify prompt from text file
- Option to specify additional/appended prompt from text file

## `runner_llama-mtd-cli.sh`, `runner_llama-cli.sh`

- Option to set model name/path via CLI
- Option to set mmproj-model name/path via CLI
- Option to pass extra arguments to CLI tool via cli flag (via `-- args` convention?)

## `runner_open-ai.sh`

- Write it!
- Pass base url via CLI arg or Env var
- Pass auth token url via CLI arg or Env var
- Pass model name url via CLI arg or Env var
- verbose flag
