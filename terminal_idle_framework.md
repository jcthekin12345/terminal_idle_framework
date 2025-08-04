# Terminal Idle Framework (TIF)

**A comprehensive framework for building terminal-based idle/incremental games**

## Project Overview

The Terminal Idle Framework provides developers with a complete toolkit to create engaging idle games that run in the terminal. It handles all the common patterns, mechanics, and UI elements that make idle games addictive, allowing developers to focus on unique gameplay mechanics and content.

## Core Idle Game Loop Types

### 1. **Resource Generation Loops**
- **Linear Growth**: Resources increase at a constant rate
- **Exponential Growth**: Growth rate increases over time
- **Compound Growth**: Multiple resources feed into each other
- **Diminishing Returns**: Growth slows as quantities increase
- **Cyclical Patterns**: Resources fluctuate in predictable cycles

### 2. **Upgrade Purchase Loops**
- **Direct Multipliers**: Increase base generation rates
- **Efficiency Upgrades**: Reduce costs or increase yields
- **Automation Upgrades**: Reduce player interaction requirements
- **Prestige Upgrades**: Permanent bonuses across resets
- **Synergy Upgrades**: Bonuses that interact with multiple systems

### 3. **Time-Based Progression Loops**
- **Real-time Progression**: Continues when game is closed
- **Active Time Bonus**: Rewards for staying engaged
- **Time Gates**: Features unlock after specific durations
- **Seasonal Events**: Time-limited bonuses and content
- **Achievement Timers**: Long-term goals spanning days/weeks

### 4. **Prestige/Reset Loops**
- **Soft Reset**: Keep some progress, gain meta-currency
- **Hard Reset**: Start over with permanent bonuses
- **Ascension**: Major progression milestone with new mechanics
- **Rebirth**: Complete restart with multiplicative bonuses
- **Evolution**: Transform the game into new stages

### 5. **Collection/Discovery Loops**
- **Resource Discovery**: Find new types of resources
- **Recipe Unlocking**: Combine resources for new items
- **Research Trees**: Unlock knowledge for bonuses
- **Achievement Hunting**: Complete challenges for rewards
- **Rare Event Collection**: Random special occurrences

## Framework Architecture

### Core Components

#### 1. **Game State Manager**
```
GameState
├── Resources (currencies, materials, energy)
├── Generators (producers, workers, machines)
├── Upgrades (multipliers, efficiency, automation)
├── Achievements (progress tracking, rewards)
├── Statistics (playtime, totals, rates)
└── Settings (preferences, display options)
```

#### 2. **Loop Engine**
```
LoopEngine
├── TickManager (handles game updates)
├── SaveSystem (persistence across sessions)
├── EventScheduler (timed events, notifications)
├── ProgressCalculator (rates, projections)
└── BalanceValidator (prevents exploits)
```

#### 3. **Display System**
```
DisplaySystem
├── LayoutManager (screen regions, responsive design)
├── ComponentRenderer (numbers, progress bars, menus)
├── ThemeEngine (colors, styles, animations)
├── InteractionHandler (keyboard, mouse input)
└── NotificationCenter (popups, alerts, achievements)
```

## Feature Set

### Resource Management
- **Multi-type Resources**: Currency, materials, energy, time
- **Resource Caps**: Storage limits with upgrade paths
- **Conversion Systems**: Transform one resource to another
- **Market Mechanics**: Buy/sell with dynamic pricing
- **Waste Management**: Resource decay and optimization

### Generator Systems
- **Manual Generators**: Click/action-based production
- **Automatic Generators**: Passive income sources
- **Conditional Generators**: Activate under specific conditions
- **Combo Generators**: Chain multiple resources together
- **Prestige Generators**: Unlock after resets

### Upgrade Trees
- **Linear Upgrades**: Simple cost/benefit progression
- **Branching Paths**: Choose between different bonuses
- **Prerequisite Systems**: Unlock advanced upgrades
- **Temporary Upgrades**: Timed bonuses and power-ups
- **Synergy Networks**: Upgrades that enhance each other

### Progression Mechanics
- **Experience Systems**: Gain XP to unlock features
- **Skill Trees**: Specialize in different game aspects
- **Milestone Rewards**: Bonuses at specific thresholds
- **Streak Bonuses**: Rewards for consistent play
- **Challenge Modes**: Optional difficulty for better rewards

### Meta-Progression
- **Prestige Currency**: Earned through resets
- **Permanent Upgrades**: Never-lost improvements
- **Research Points**: Unlock new game mechanics
- **Legacy Bonuses**: Benefits from previous runs
- **Mastery Systems**: Expertise in specific areas

## Terminal UI Components

### Display Elements
- **Resource Counters**: Animated number displays with suffixes
- **Progress Bars**: Visual representation of completion
- **Rate Indicators**: Current generation/consumption rates
- **Efficiency Meters**: Performance optimization displays
- **Time Remaining**: Countdown timers for events

### Interactive Elements
- **Button Menus**: Keyboard navigation systems
- **Tabbed Interfaces**: Organize complex information
- **Scrollable Lists**: Handle large amounts of content
- **Input Forms**: Configure settings and preferences
- **Confirmation Dialogs**: Prevent accidental actions

### Visual Enhancements
- **ASCII Art**: Game logos and decorative elements
- **Color Coding**: Status indicators and categories
- **Animation Effects**: Smooth transitions and feedback
- **Layout Themes**: Different visual styles
- **Responsive Design**: Adapt to terminal sizes

## Game Templates

### 1. **Cookie Clicker Style**
- Manual clicking for base resource
- Automatic generators (grandmas, factories)
- Exponential cost scaling
- Achievement system
- Simple prestige mechanic

### 2. **Mining/Crafting Game**
- Extract raw materials
- Process into refined goods
- Build complex production chains
- Research new technologies
- Market trading systems

### 3. **City Builder Idle**
- Population growth mechanics
- Building construction and upgrades
- Resource management (food, energy, materials)
- Citizen happiness systems
- Urban planning optimization

### 4. **RPG Character Growth**
- Stat progression (strength, magic, etc.)
- Equipment upgrades and crafting
- Quest completion rewards
- Skill tree development
- Enemy encounters and battles

### 5. **Space Exploration**
- Planet discovery and colonization
- Resource extraction across systems
- Spaceship upgrades and fleet building
- Research for new technologies
- Galactic expansion mechanics

## Configuration System

### Game Balance Files
```yaml
resources:
  coins:
    display_name: "Gold Coins"
    initial_amount: 0
    display_format: "currency"
    cap: null
    
generators:
  coin_generator:
    base_rate: 1.0
    cost_scaling: 1.15
    base_cost: 10
    
upgrades:
  click_multiplier:
    type: "multiplier"
    target: "manual_generation"
    levels: 100
    cost_formula: "base * (1.5 ^ level)"
```

### Display Configuration
```yaml
layout:
  header_height: 3
  footer_height: 2
  sidebar_width: 30
  
colors:
  resource_positive: "green"
  resource_negative: "red"
  upgrade_available: "yellow"
  upgrade_unavailable: "dark_gray"
  
animations:
  number_change_duration: 500ms
  progress_bar_speed: 250ms
```

## API Documentation

### Core Classes

#### GameLoop
```python
class GameLoop:
    def __init__(self, config: GameConfig)
    def start(self) -> None
    def pause(self) -> None
    def resume(self) -> None
    def save_game(self, filename: str) -> bool
    def load_game(self, filename: str) -> bool
    def add_resource(self, resource: Resource) -> None
    def add_generator(self, generator: Generator) -> None
    def register_upgrade(self, upgrade: Upgrade) -> None
```

#### Resource
```python
class Resource:
    def __init__(self, name: str, initial: float = 0)
    def add(self, amount: float) -> float
    def subtract(self, amount: float) -> bool
    def set_cap(self, cap: float) -> None
    def get_display_string(self) -> str
    def get_rate(self) -> float
```

#### Generator
```python
class Generator:
    def __init__(self, name: str, base_rate: float)
    def set_target_resource(self, resource: Resource) -> None
    def calculate_production(self, delta_time: float) -> float
    def upgrade(self, multiplier: float) -> None
    def toggle_active(self) -> None
```

#### Upgrade
```python
class Upgrade:
    def __init__(self, name: str, cost: float, effect: Effect)
    def can_afford(self, resources: Dict[str, Resource]) -> bool
    def purchase(self, resources: Dict[str, Resource]) -> bool
    def get_next_cost(self) -> float
    def get_description(self) -> str
```

## Implementation Examples

### Basic Resource Game
```python
# Create the game loop
game = GameLoop(GameConfig.from_file("basic_idle.yaml"))

# Add resources
gold = Resource("gold", 0)
gems = Resource("gems", 0)
game.add_resource(gold)
game.add_resource(gems)

# Add generators
gold_mine = Generator("gold_mine", base_rate=1.0)
gold_mine.set_target_resource(gold)
game.add_generator(gold_mine)

# Add upgrades
better_pickaxe = Upgrade("better_pickaxe", cost=100, 
                        effect=MultiplierEffect(gold_mine, 2.0))
game.register_upgrade(better_pickaxe)

# Start the game
game.start()
```

### Custom Game Loop
```python
class MyIdleGame(IdleGameBase):
    def setup_resources(self):
        self.add_resource("energy", initial=100, cap=1000)
        self.add_resource("matter", initial=0)
        self.add_resource("research", initial=0)
    
    def setup_generators(self):
        solar_panel = Generator("solar_panel", 
                               base_rate=0.5, 
                               target="energy")
        self.add_generator(solar_panel)
    
    def setup_upgrades(self):
        efficiency_upgrade = Upgrade(
            name="Efficient Solar Panels",
            cost={"energy": 500},
            effect=MultiplierEffect("solar_panel", 1.25)
        )
        self.add_upgrade(efficiency_upgrade)
    
    def custom_update_logic(self, delta_time):
        # Convert energy to matter if energy is full
        if self.resources["energy"].is_at_cap():
            energy_to_convert = self.resources["energy"].amount * 0.1
            self.resources["energy"].subtract(energy_to_convert)
            self.resources["matter"].add(energy_to_convert * 0.1)
```

## Performance Considerations

### Optimization Strategies
- **Batch Updates**: Process multiple ticks together when catching up
- **Delta Compression**: Efficient save/load for large numbers
- **Lazy Calculation**: Only compute visible information
- **Memory Pooling**: Reuse objects to reduce garbage collection
- **Progressive Loading**: Load game content as needed

### Scalability Features
- **Big Number Support**: Handle extremely large values gracefully
- **Async Processing**: Non-blocking saves and calculations
- **Modular Architecture**: Easy to add/remove game systems
- **Configuration-Driven**: Modify gameplay without code changes
- **Plugin System**: Third-party extensions and modifications

## Development Roadmap

### Phase 1: Core Framework (v1.0)
- [ ] Basic game loop with save/load
- [ ] Resource and generator systems
- [ ] Simple upgrade mechanics
- [ ] Terminal UI with basic components
- [ ] Configuration system
- [ ] Documentation and examples

### Phase 2: Advanced Features (v1.5)
- [ ] Prestige/reset mechanics
- [ ] Achievement system
- [ ] Multiple game templates
- [ ] Advanced UI components
- [ ] Theme and customization support
- [ ] Performance optimizations

### Phase 3: Community Features (v2.0)
- [ ] Plugin architecture
- [ ] Modding support
- [ ] Game sharing and import/export
- [ ] Community template library
- [ ] Advanced scripting capabilities
- [ ] Multi-platform packaging

### Phase 4: Polish and Extension (v2.5)
- [ ] Advanced graphics mode (Unicode/emoji)
- [ ] Sound effects support
- [ ] Multiplayer/social features
- [ ] Mobile terminal support
- [ ] Web-based version
- [ ] Commercial game licensing

## Getting Started

### Installation
```bash
pip install terminal-idle-framework
```

### Quick Start
```bash
# Create a new idle game project
tif create my-idle-game

# Run the development server
cd my-idle-game
tif run --dev

# Build for distribution
tif build --target all
```

### Example Projects
- **examples/cookie_clicker/**: Basic clicking game
- **examples/mining_game/**: Resource extraction and processing
- **examples/city_builder/**: Population and building management
- **examples/rpg_idle/**: Character progression and combat
- **examples/space_exploration/**: Multi-planet resource management

## Contributing

### Development Setup
```bash
git clone https://github.com/your-org/terminal-idle-framework
cd terminal-idle-framework
pip install -e .[dev]
pytest tests/
```

### Contribution Guidelines
- Follow PEP 8 style guidelines
- Write comprehensive tests for new features
- Update documentation for API changes
- Submit examples for new game mechanics
- Report bugs with minimal reproduction cases

## License

MIT License - See LICENSE file for details

## Community

- **Discord**: [Terminal Idle Games](https://discord.gg/terminal-idle)
- **Reddit**: [r/TerminalIdleGames](https://reddit.com/r/terminalidle)
- **GitHub**: [Issues and Discussions](https://github.com/your-org/terminal-idle-framework)
- **Documentation**: [Full API Reference](https://docs.terminal-idle.dev)

---

*Build the next great idle game that runs anywhere a terminal does!*