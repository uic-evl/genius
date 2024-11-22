timeout=600
echo Timeout: $timeout seconds until simulation shutdown
echo ""
sleep $timeout
echo ""
echo Timeout: $timeout seconds have elapsed, killing jupyter
pkill jupyter-noteboo
