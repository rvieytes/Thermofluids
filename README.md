# Termofluids

**Termofluids** is the repository that supports the teaching material for **Thermofluidos I and Thermofluidos II**, courses in the Mechanical Engineering program at the **Instituto Tecnológico de Buenos Aires (ITBA)**..

It provides a common environment for the numerical software used to support the extended notes, lectures, examples, and computational activities of the courses.

The repository contains shared libraries, standalone projects, chapter-specific scripts, documentation, and templates.

## Repository structure

```text
Termofluids/
├── lib/
├── projects/
├── chapters/
├── docs/
└── templates/
```

### `lib/`

Shared libraries and reusable computational components.

These libraries are intended to be used by different projects and chapter-specific scripts.

### `projects/`

Standalone computational projects and applications.

Projects may use components from `lib/` but have their own structure and purpose.

### `chapters/`

Computational material associated with the course notes and individual chapters.

Scripts located under a chapter are generally intended to solve specific problems, generate figures, demonstrate concepts, or support examples presented in that chapter.

### `docs/`

Published documentation and course notes.

This directory contains PDF documents intended for distribution. LaTeX source files are not part of this repository.

### `templates/`

Templates and starting structures for new scripts and projects within the Termofluids environment.

## The Termofluids environment

The software in this repository is designed to operate under the **Termofluids repository structure**.

Python scripts use a bootstrap mechanism to locate the repository root and automatically make:

```text
Termofluids/lib/python/
```

available to the Python import system.

This allows scripts located in different parts of the repository to use the shared libraries without requiring project-specific path configuration.

For example:

```python
from thermophysics import Fluid
```

can be used by a script located under `chapters/` or `projects/`.

## Working outside the Termofluids repository

The Termofluids directory structure is part of the software environment.

If a script, project, or library is copied or moved outside the Termofluids repository, its operation is no longer guaranteed by this framework.

In that case, the user is responsible for configuring the required:

* Python paths;
* dependencies;
* external software;
* environment variables;
* file and directory paths;
* other resources required by the particular project.

The software is therefore distributed under the assumption that it is used within the Termofluids repository structure.

## Scope

This repository is primarily intended to support:

* Thermofluidos I;
* Thermofluidos II;
* the corresponding extended notes;
* numerical examples and demonstrations;
* computational projects related to the courses.

The structure is designed to keep reusable scientific software separate from project-specific applications and chapter-specific scripts.

The extended course notes are written in Spanish.

## License

The educational material and software distributed in this repository are released under a Creative Commons (CC) license. See the applicable license terms for details.
