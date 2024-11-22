email="youremailhere@gmail.com"

echo ""
echo "Your simulation has become unstable! Access jupyter to investigate: http://localhost:8888/tree"

# Uncomment to also send yourself an email
# echo "Your simulation has become unstable! Access jupyter to investigate: http://localhost:8888/tree" | mail -s "Unstable Simulation Test" $email

# rm unstable_actions.yaml
# cp shutdown.yaml unstable_actions.yaml

nohup jupyter notebook --ip 0.0.0.0 --port 8888 --IdentityProvider.token='' --no-browser --NotebookApp.token='' --NotebookApp.password='' >/dev/null 2>&1 &
./timeout.sh &
