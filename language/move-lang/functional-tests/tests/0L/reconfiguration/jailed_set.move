// Test that both cases 3 and 4 are jailed.

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0, validator
//! account: frank, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: alice
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;

    fun main(sender: &signer) {
        // Alice mines (case 1)
        // "Sender" is the only one that can update her mining stats. Hence this first transaction.

        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count({{alice}}) == 5, 7357120201011000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;

    fun main(sender: &signer) {
        // Eve mines (case 3)
        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count({{eve}}) == 5, 7357120202011000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: association
script {
    use 0x0::Stats;
    use 0x0::Vector;
    use 0x0::Cases;
    use 0x0::Transaction::assert;
    use 0x0::LibraSystem;

    fun main() {
        let voters = Vector::singleton<address>({{alice}});
        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&voters);
            i = i + 1;
        };

        assert(Cases::get_case({{alice}}) == 1, 7357120203011000);
        assert(Cases::get_case({{eve}}) == 3, 7357120203021000);
        assert(Cases::get_case({{frank}}) == 4, 7357120203031000);

        let jailed = LibraSystem::get_jailed_set();
        assert(Vector::length<address>(&jailed) == 5, 7357120203041000);
    }
}
//check: EXECUTED