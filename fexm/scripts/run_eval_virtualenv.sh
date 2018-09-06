#!/bin/bash
if [ "$#" -lt 1 ]; then
    echo "Usage: run_eval.sh <config.json>"
    exit -1
fi
if [ ! -f $1 ]; then 
    echo "Configuration file not found!"
    exit -1
fi
cpu_count=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)
concurrency=${2:-$cpu_count}
tmux new -s "celery_scheduler" -d
tmux send-keys -t "celery_scheduler" "source env/bin/activate && cd fexm/celery_tasks && celery -A tasks purge -f && celery -A tasks worker -l INFO --concurrency=$concurrency" C-m
tmux new -s "run_eval_task" -d
tmux send-keys -t "run_eval_task" "source env/bin/activate && fexm/tools/eval_manager_pacman.py $1" C-m
sleep 30
tmux new -s "webserver" -d
tmux send-keys -t "webserver" "source env/bin/activate && fexm/webserver/webserver.py -c $1" C-m
echo "Started fexm for specified config. Attach using \"tmux attach -t 'run_eval_task' -d\" or check the dashboard on port 5307."
#tmux attach -t "run_eval_task" -d
