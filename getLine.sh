#!/bin/bash

start=$2;
get=3$;
$(tail -n +$start $1 | head -n $get);
