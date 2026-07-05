@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0capture_android_qa_evidence.ps1" %*
