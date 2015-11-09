:: This is simply a file to test the program in case it crashes.
:: In normal use cases, you won't need this file to run.

@echo off
:start
ruby DCserver.rb
Choice /M "Keep going?"
If Errorlevel 2 Goto end
If Errorlevel 1 Goto start
GOTO start
:end
exit