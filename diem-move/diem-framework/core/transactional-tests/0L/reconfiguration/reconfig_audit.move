// Testing if EVE failing audit gets dropped.

// ALICE is CASE 1
//! account: alice, 1000000, 0, validator
// BOB is CASE 1
//! account: bob, 1000000, 0, validator
// CAROL is CASE 1
//! account: carol, 1000000, 0, validator
// DAVE is CASE 1
//! account: dave, 1000000, 0, validator
// EVE fails audit
//! account: eve, 1000000, 0, validator
// FRANK is CASE 2
//! account: frank, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::ValidatorConfig;

    fun main(sender: signer) {
        // Transfer enough coins to operators
        let oper_bob = ValidatorConfig::get_operator(@Bob);
        let oper_eve = ValidatorConfig::get_operator(@Eve);
        let oper_dave = ValidatorConfig::get_operator(@Dave);
        let oper_alice = ValidatorConfig::get_operator(@Alice);
        let oper_carol = ValidatorConfig::get_operator(@Carol);
        let oper_frank = ValidatorConfig::get_operator(@Frank);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Bob, oper_bob, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Eve, oper_eve, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Dave, oper_dave, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, oper_alice, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Carol, oper_carol, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Frank, oper_frank, 50009, x"", x"", &sender);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);
        
        // Miner is the only one that can update their mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Alice) == 5, 7357008015001);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);
        
        // Miner is the only one that can update their mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008015002);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: carol
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);
        
        // Miner is the only one that can update their mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008015003);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: dave
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);
        
        // Miner is the only one that can update their mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008015004);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use DiemFramework::TowerState;

    fun main(sender: signer) {
        // Skip eve forcing audit to fail
        // AutoPay::enable_autopay(&sender);
        
        // Miner is the only one that can update their mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Eve) == 5, 7357008015005);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Stats;
    use Std::Vector;
    use DiemFramework::DiemSystem;

    fun main(vm: signer) {
        let voters = Vector::singleton<address>(@Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);
        Vector::push_back<address>(&mut voters, @Dave);
        Vector::push_back<address>(&mut voters, @Eve);
        Vector::push_back<address>(&mut voters, @Frank);

        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&vm, &voters);
            i = i + 1;
        };

        assert!(DiemSystem::validator_set_size() == 6, 7357008009006);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357008015006);
    }
}
//check: EXECUTED

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 61000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemConfig;

    fun main(_account: signer) {
        // We are in a new epoch.
        assert!(DiemConfig::get_current_epoch() == 2, 7357008015007);
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 4, 7357008015008);
        assert!(DiemSystem::is_validator(@Eve) == false, 7357008015009);
    }
}
//check: EXECUTED