LIBRA_SOURCE_DIRECTORY=$HOME/workspace/libra/libra
ACCOUNT_ADDRESS=851A3BAF866951B36A3FE0DA92BA38FC

# Find out if an account is jailed
ol -a $ACCOUNT_ADDRESS query -r | sed -n '/is_jailed/,/StructTag/p'

# Find how much GAS is unlocked for a validator to transfer
cd $LIBRA_SOURCE_DIRECTORY && cargo r -p diem-transaction-replay -- --db $HOME/.0L/db annotate-account $ACCOUNT_ADDRESS | grep unlocked | tail -n 1 | awk '/[unlockedl:]/ {print hello ($2/1000000)}' | xargs echo "Unlocked: " && cd -

# create and view dump file of account data
cd $LIBRA_SOURCE_DIRECTORY && cargo r -p diem-transaction-replay -- --db $HOME/.0L/db annotate-account ${ACCOUNT_ADDRESS} > /tmp/dump-self && cd - && cat /tmp/dump-self | less

# Find voted rounds info in logs
ag last_voted_round $HOME/.0L/logs/

# Reset waypoint and restart node
ol init --key-store --waypoint <waypoint>


ol query --epoch

ol restore -e 356 -v 76053234

# BBB
mkdir ~/epoch-archive/357

# epoch-ending snapshot
db-backup one-shot backup --backup-service-address http://localhost:6186 epoch-ending --start-epoch 356 --end-epoch 357 local-fs --dir ~/epoch-archive/357

# get waypoint from epoch-ending manifest
jq -r ".waypoints[0]" ~/epoch-archive/357/ep*/epoch_ending.manifest

# result from previous
75827345:8a6a78c3600b9c75f4ee90f36d398d948339d680fb4da15440f05df1fe304e9e

# get height from waypoint
echo "75827345:8a6a78c3600b9c75f4ee90f36d398d948339d680fb4da15440f05df1fe304e9e" | cut -d ":" -f 1

# take transaction snapshot
db-backup one-shot backup --backup-service-address http://localhost:6186 transaction --num_transactions 1 --start-version 75827345 local-fs --dir ~/epoch-archive/357


# KBN (did not work on BBB)
db-backup one-shot backup --backup-service-address http://localhost:6186 state-snapshot --state-version 75827345 local-fs --dir ~/epoch-archive/357

# zip
tar -czvf 357.tar.gz 357


# get version of current db
db-backup one-shot query node-state | cut -d ":" -d "," -f 2 | cut -d ":" -f 2| xargs

76053607

# commit
git add -A && git commit -a -m "epoch archive 586 - 75827345 - 76053607" && git push




[profile]
...
# bigbubbabeast, polo, thenateway, daniyal
upstream_nodes = ["http://142.132.207.31:8080/","http://144.76.104.93:8080/","http://5.161.130.81:8080/","http://135.181.118.28:8080/"]

...
[tx_configs.miner_txs_cost]
max_gas_unit_for_tx = 100000
coin_price_per_unit = 1
user_tx_timeout = 30000

[tx_configs.cheap_txs_cost]
max_gas_unit_for_tx = 100000
coin_price_per_unit = 1
user_tx_timeout = 30000



### Standard vanilla transaction
`txn transfer -c <amount> -a <address>`


dump:
    mkdir ${RESCUE_PATH} | true
-   cd ${SOURCE_PATH} && cargo r -p diem-transaction-replay -- --db ${DATA_PATH}/db annotate-account ${ACCOUNT} > ${RESCUE_PATH}/dump-${STEP}
+   cd /home/hemulin/workspace/libra/libra/ && cargo r -p diem-transaction-replay -- --db ${DATA_PATH}/db annotate-account ${ACCOUNT} > ${RESCUE_PATH}/dump-${STEP}
+   # cd ${SOURCE_PATH} && cargo r -p diem-transaction-replay -- --db ${DATA_PATH}/db annotate-account ${ACCOUNT} > ${RESCUE_PATH}/dump-${STEP}
