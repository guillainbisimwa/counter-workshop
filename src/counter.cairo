#[derive(starknet::Event, Drop)]
#[starknet::interface]
trait ICounter<TContractState> {
    fn get_counter(self: @TContractState) -> u32;
    fn increase_counter(ref self: TContractState);
}

#[starknet::contract]
pub mod counter_contract {
    use starknet::event::EventEmitter;
    use starknet::ContractAddress;
    use kill_switch::{IKillSwitchDispatcher, IKillSwitchDispatcherTrait};

    #[storage]
    struct Storage {
        counter: u32,
        kill_switch: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, 
        initial_value: u32,
        kill_switch: ContractAddress,
    ) {
        self.counter.write(initial_value);
        self.kill_switch.write(kill_switch);
    }

    #[event]
    #[derive(starknet::Event, Drop)]
    enum Event {
        CounterIncreased: CounterIncreased,
    }

    #[derive(starknet::Event, Drop)]
    struct CounterIncreased {
        value: u32
    }

    #[external(v0)]
    fn get_counter(ref self: ContractState) -> u32 {
        self.counter.read()
    }
    
    #[external(v0)]
    fn increase_counter(ref self: ContractState) {

        let kill_switch = IKillSwitchDispatcher { contract_address: self.kill_switch.read(), };

        assert!(!kill_switch.is_active(), "Kill Switch is active");
        
        if !kill_switch.is_active() {
            self.counter.write(self.counter.read() + 1);
            self.emit(CounterIncreased { value: self.counter.read() });
        }
    }
}

// - Create the condition to revert the transaction if the `KillSwith` contract is enabled
// - Revert the transaction with the following message 
// `Kill Switch is active`
