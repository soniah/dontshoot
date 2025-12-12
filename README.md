# Creating a Self-Hosted Private Podcast Feed from a PDF or Text Source

This document explains how to turn text into a set of audio files delivered
through a self-hosted podcast feed using GitHub Pages.

The workflow:

1. Extract text from a PDF  
2. Convert text → speech using macOS `say`  
3. Convert AIFF → M4A  
4. Split audio into chapters or segments  
5. Repair timing/index issues in the audio container  
6. Build an RSS feed  
7. Host on GitHub Pages  
8. Subscribe with any podcast app

---

## 1. Extract Text from a PDF

If the PDF is selectable text:

```bash
pdftotext input.pdf output.txt
```

If the PDF contains scanned images:

```bash
ocrmypdf input.pdf ocr_output.pdf
pdftotext ocr_output.pdf output.txt
```

---

## 2. Convert Text to AIFF Using macOS `say`

```bash
say -v "jamie" -o full.aiff -f output.txt
```

List voices:

```bash
say -v '?'
```

---

## 3. Convert AIFF → M4A

```bash
afconvert -f m4af -d aac full.aiff full.m4a
```

---

## 4. Split the Audio into Segments

Even time segments:

```bash
ffmpeg -i full.m4a -f segment -segment_time 1200 -c copy part_%03d.m4a
```

Specific timestamps:

```bash
ffmpeg -i full.m4a -ss 00:00:00 -to 00:25:00 -c copy seg_000.m4a
ffmpeg -i full.m4a -ss 00:25:00 -to 00:50:00 -c copy seg_001.m4a
ffmpeg -i full.m4a -ss 00:50:00 -c copy seg_002.m4a
```

---

## 5. Fix Audio Timing / Seeking Issues

Lossless remux:

```bash
ffmpeg -i seg_000.m4a -c copy -movflags +faststart fixed_000.m4a
```

Batch:

```bash
mkdir fixed
for f in seg_*.m4a; do
    ffmpeg -i "$f" -c copy -movflags +faststart "fixed/$f"
done
```

If broken, re-encode:

```bash
ffmpeg -i seg_000.m4a -c:a aac -b:a 96k -movflags +faststart fixed_000.m4a
```

---

## 6. Create a Minimal Podcast RSS Feed

Example structure:

```
podcast/
  <obfuscated-id>/
      seg_000.m4a
      seg_001.m4a
      rss.xml
```

RSS template:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>My Private Audio Feed</title>
    <link>https://USERNAME.github.io/REPO/podcast/<id>/</link>
    <description>Private feed</description>
    <language>en-us</language>

    <item>
      <title>Segment 000</title>
      <enclosure url="https://USERNAME.github.io/REPO/podcast/<id>/seg_000.m4a"
                 type="audio/x-m4a"
                 length="12345678" />
      <guid>unique-guid-here</guid>
      <pubDate>Tue, 01 Jan 2030 00:00:00 GMT</pubDate>
    </item>

  </channel>
</rss>
```

Use MIME type `audio/x-m4a`.

---

## 7. Host the Files with GitHub Pages

```bash
git init
git add .
git commit -m "initial"
git remote add origin git@github.com:USERNAME/REPO.git
git branch -M main
git push -u origin main
```

Enable Pages:

Settings → Pages  
- Source: *Deploy from a branch*  
- Branch: `main`  
- Folder: `/`  

Feed URL:

```
https://USERNAME.github.io/REPO/podcast/<id>/rss.xml
```

---

## 8. Subscribe in a Podcast App

Add podcast by URL → paste RSS feed.

If audio doesn’t play:

- Ensure enclosure MIME type is `audio/x-m4a`  
- Verify file loads in a browser  
- Fix timing using ffmpeg (Section 5)

---

## Summary

This README covers:

- Extracting text from PDFs  
- Converting text → audio  
- Splitting audio  
- Repairing timing issues  
- Generating an RSS feed  
- Publishing via GitHub Pages  
- Subscribing through a podcast app  

Automatable via scripts or Makefiles as needed.
