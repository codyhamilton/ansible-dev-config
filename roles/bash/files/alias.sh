#!/bin/bash

alias ll="ls -lG";

function v() { vim -c "CommandT" -c "normal $@"; }
