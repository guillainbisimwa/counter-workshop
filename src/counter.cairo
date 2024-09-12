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
        self.counter.write(self.counter.read() + 1);
        self.emit(CounterIncreased { value: self.counter.read() });
    }
}



// 1. Store a variable named `kill_switch` as type `ContractAddress`.
// 2. Update the constructor function to initialize the `kill_switch` variable.
