#!/usr/bin/env bash

set -e

bundle exec rake
cd example
bundle exec rake docs:generate
