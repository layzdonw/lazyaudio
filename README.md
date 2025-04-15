# Lazy Audio

## Introduction

LazyAudio is a macOS application designed for easy audio recording and management. **Its core feature is performing real-time transcription locally using Sherpa-onnx**, capturing audio from your system or microphone. After transcription, it leverages **Large Language Models (LLMs) to automatically generate summaries, tasks, translations, mind maps, and more** based on the audio content.

## Features

*   **Local Real-time Transcription**: Uses `Sherpa-onnx` to transcribe system audio or microphone input directly on your Mac, ensuring privacy and speed.
*   **AI-Powered Post-Processing**: Automatically generate insights from transcriptions:
    *   Summaries
    *   Actionable Tasks
    *   Translations
    *   Mind Maps
    *   (Other potential AI features)
*   **Flexible Audio Recording**: Record audio from system output or microphone input.
*   **Recording Management**: Easily start, stop, and organize your recording sessions.
*   **Recording History**: Access a list of your past recordings and their transcriptions/analyses.
*   **Search & Filter**: Quickly find specific recordings or content within transcriptions.
*   **Dark/Light Mode**: Switch between visual themes to suit your preference.
*   **Multi-language Support**: The interface is available in multiple languages.
*   **Menu Bar Access**: Conveniently control recording functions via menu bar commands.

## Getting Started

**Prerequisites:**

*   macOS [Specify minimum required version, e.g., 13.0 or later]
*   Xcode [Specify minimum required version, e.g., 15.0 or later] (if building from source)

**Installation:**

*   **From Release:** Download the latest `.dmg` or `.zip` file from the [Releases page](link-to-releases-page) (Add link here) and install the application.
*   **From Source:**
    1.  Clone the repository: `git clone https://github.com/your-username/lazyaudio.git` (Replace with actual URL)
    2.  Open `LazyAudio.xcodeproj` in Xcode.
    3.  Select the `LazyAudio` scheme and your target device (My Mac).
    4.  Build and run the application (Cmd+R).

**Basic Usage:**

1.  Launch LazyAudio.
2.  Select the desired audio source (System Audio, a specific App, or Microphone).
3.  Click the "Record" button to start recording.
4.  Click the "Stop" button when finished.
5.  Access your recordings in the "History" section.

## Contributing

Contributions are welcome! If you'd like to contribute, please follow these steps:

1.  **Fork the repository** on GitHub.
2.  **Create a new branch** for your feature or bug fix: `git checkout -b feature/your-feature-name` or `bugfix/issue-description`.
3.  **Make your changes** and commit them with clear, descriptive messages.
4.  **Push your branch** to your forked repository: `git push origin feature/your-feature-name`.
5.  **Open a Pull Request** from your branch to the `main` branch of the original repository.
6.  Ensure your code adheres to the project's coding style and includes relevant tests if applicable.
7.  Clearly describe the changes you've made and the problem they solve in the Pull Request description.

We appreciate your contributions to making LazyAudio better!

## License

This project is licensed under the **Apache License 2.0**. See the `LICENSE` file for details.