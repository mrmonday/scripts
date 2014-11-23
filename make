#!/bin/zsh

MAX_COMPLETION_TIME=5

# Convert a number of seconds into human readable format
function to_human() {
    zmodload zsh/mathfunc

    local ms=$(($1 * 100 % 100))
    local s=$((int($1) % 60))
    local m=$((int($1) / 60 % 60))
    local h=$((int($1) / (60 * 60) % 24))
    local d=$((int($1) / (60 * 60 * 24)))

    (( $d > 0 )) && echo -n "${d}d "
    (( $h > 0 )) && echo -n "${h}h "
    (( $m > 0 )) && echo -n "${m}m "
    (( $s > 0 )) && echo -n "${s}s "
    (( $ms > 0 )) && echo -n "${ms}ms "
}

# diable built in time
disable -r time

total_time=$(mktemp)
start_time=$(date +%s)

time -o $total_time -f %e make "$@"
return_val=$?

time_taken=$(cat $total_time)

if (( $return_val != 0 )); then
    end_time=$(date +%s)
    if (( $end_time - $start_time > $MAX_COMPLETION_TIME )); then
        notify-send -t 0 -u critical "make failed" "make $*"
    fi
elif (( $time_taken > $MAX_COMPLETION_TIME )); then
    human_time=$(to_human $time_taken)
    notify-send -t 0 "make complete in $human_time" "make $*"
fi

rm $total_time
enable -r time

exit $return_val
