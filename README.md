# 🌊 DeepSeeker Robothon

> **Autonomous Submarine System for Seabed Mapping & Undersea Cable Route Surveying**

[![MATLAB](https://img.shields.io/badge/MATLAB-R2023a+-orange?logo=mathworks)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Competition](https://img.shields.io/badge/KUEC%20Robothon-2025-green)](https://robothon.ku.edu)

---

## 📖 Overview

**DeepSeeker** is an autonomous submarine simulation system designed for seabed terrain mapping and undersea cable route surveying. Built for the **KUEC Robothon 2025 - Track 1: Autonomous Navigation & Mapping**, this project demonstrates advanced robotics concepts including:

- 🤖 Autonomous underwater navigation
- 📡 LiDAR-based terrain scanning
- 🗺️ Real-time 3D mapping
- 🧭 A* path planning for optimal cable routes
- 🎮 PID control systems

---

## 🎯 Features

| Feature | Description |
|---------|-------------|
| **3D Terrain Generation** | Realistic seabed with obstacles, trenches, and slopes |
| **32-Channel LiDAR** | Simulated underwater LiDAR with 30m range |
| **Path Planning** | A* algorithm for finding optimal cable-laying routes |
| **Safety Analysis** | Slope and roughness analysis for cable feasibility |
| **Cinematic Visualization** | Professional 3D animations with CAD model import |
| **Real-time Obstacle Avoidance** | Dynamic path adjustment based on sensor data |

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    DeepSeeker Submarine System                   │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐    │
│  │  Sensors  │  │  Control  │  │  Planning │  │ Visualize │    │
│  ├───────────┤  ├───────────┤  ├───────────┤  ├───────────┤    │
│  │ • LiDAR   │  │ • Depth   │  │ • A* Path │  │ • 3D View │    │
│  │ • Sonar   │──│ • Heading │──│ • Obstacle│──│ • Terrain │    │
│  │ • IMU     │  │ • Speed   │  │ • Route   │  │ • Charts  │    │
│  │ • Depth   │  │ • PID     │  │ • Safety  │  │ • Results │    │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Simulation Results

### Terrain Mapping
The system generates a 100m x 100m survey area with realistic seabed features:

- **Base depth**: 50 meters
- **Obstacles**: 15 randomly placed rocks, trenches, and slopes
- **Resolution**: 1 meter grid

### Path Planning Output
The A* algorithm computes an optimal path considering:
- Maximum slope: 15°
- Minimum obstacle clearance: 3m
- Terrain roughness threshold: 2m

### Safety Zone Analysis
```
┌────────────────────────────────────────┐
│  🟢 Green  - Safe for cable laying     │
│  🟡 Yellow - Caution required          │
│  🔴 Red    - Unsafe terrain            │
└────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

- MATLAB R2023a or later
- Simulink (optional, for advanced simulations)
- Simscape Multibody (optional, for CAD model import)

### Installation

```bash
git clone https://github.com/simreensiraj/DeepSeeker-Robothon.git
cd DeepSeeker-Robothon
```

### Running the Simulation

1. **Setup the environment:**
   ```matlab
   setup_seabed_mapping
   ```

2. **Run the survey simulation:**
   ```matlab
   run_seabed_survey
   ```

3. **View cinematic demo:**
   ```matlab
   cinematic_submarine_demo
   ```

---

## 📁 Project Structure

```
DeepSeeker-Robothon/
├── 📄 setup_seabed_mapping.m      # Initialize terrain & parameters
├── 📄 run_seabed_survey.m         # Execute survey mission
├── 📄 cinematic_submarine_demo.m  # 3D animation demo
├── 📄 compute_cable_route.m       # A* path planning
├── 📄 simulate_lidar_scan.m       # LiDAR sensor simulation
├── 📄 obstacle_avoidance.m        # Collision avoidance logic
├── 📄 visualize_survey_results.m  # Generate charts & figures
├── 📄 animate_submarine.m         # Animation utilities
├── 📄 animate_underwater_scanning.m
├── 📄 show_submarine.m
├── 📄 view_submarine_model.m
├── 🔧 Submarine.step              # CAD model (STEP format)
├── 🔧 Submarine.stl               # CAD model (STL format)
├── 📊 seabed_mapping_params.mat   # Saved configuration
└── 📊 seabed_survey_results.mat   # Simulation results
```

---

## ⚙️ Configuration

### Submarine Parameters
| Parameter | Value | Unit |
|-----------|-------|------|
| Mass | 25 | kg |
| Length | 0.6 | m |
| Diameter | 0.15 | m |
| Drag Coefficient | 0.82 | - |

### Sensor Suite
| Sensor | Specification |
|--------|--------------|
| LiDAR | 32 channels, 30m range, 360° FOV |
| Sonar | 50m range, 5 Hz |
| IMU | 100 Hz, ±0.01 m/s² noise |
| Depth | 50 Hz, ±0.05m accuracy |

### PID Controllers
| Controller | Kp | Ki | Kd |
|------------|----|----|-----|
| Depth | 50 | 5 | 10 |
| Heading | 30 | 2 | 8 |
| Speed | 20 | 1 | 5 |

---

## 📈 Performance Metrics

After running a typical 10-minute survey:

| Metric | Value |
|--------|-------|
| Survey Duration | 600 seconds |
| Distance Traveled | ~200 meters |
| Average Speed | 1.5 m/s |
| LiDAR Scans | 600+ |
| Path Safety Score | ✅ Excellent |

---

## 🎥 Demo

Run the cinematic demo to see the submarine in action:

```matlab
cinematic_submarine_demo
```

Features:
- Real-time 3D underwater environment
- Animated LiDAR scanning beams
- Dynamic camera following
- Cable detection visualization

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

**DeepSeeker Team** - KUEC Robothon 2025
Yuvan Whabi
Simreen Siraj Shehzadi
Hishaam Abdul Razik
Osama Tariq Ahmed
Abd AlRahman
Mohammed Fizal
Harinath Ranjith

---

## 🙏 Acknowledgments

- KUEC Robothon 2025 organizers
- MathWorks for MATLAB/Simulink
- The underwater robotics research community

---

<div align="center">

**Built with ❤️ for KUEC Robothon 2025**

</div>
