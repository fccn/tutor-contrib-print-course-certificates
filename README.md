print-course-certificates plugin for Tutor
---------------

Installs the [nau-course-certificate](https://github.com/fccn/nau-course-certificate/) project that allows to print course certificates to PDF on server side.

Requires change the Download Certificate button to be changed to use this application.

Features:
- Generate PDF document server side, so they have consistent presentation
- Digital sign the PDF
- PDF generation cache on S3 Bucket

## Installation

```bash
pip install git+https://github.com/fccn/tutor-contrib-print-course-certificates@v18.0.0
```

## Usage

```bash
tutor plugins enable print-course-certificates
```

## License

This software is licensed under the terms of the AGPLv3.