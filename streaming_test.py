#!/usr/bin/env python3
"""
MaRCoS Streaming Function Test

Simple script to validate streaming functionality without visualizations or extra features.
"""

import sys
import socket
import time
import traceback
import numpy as np
import msgpack

# Add client path
sys.path.append('/workspaces/marcos_pack/marcos_client')

from local_config import ip_address, port
from server_comms import command
import experiment as ex

def run_basic_streaming_test():
    print(f"Testing streaming functionality with server at {ip_address}:{port}")
    
    # Create socket
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    try:
        # Connect
        print("Connecting to server...")
        s.connect((ip_address, port))
        print("Connected!")
        
        # Get version - even though there might be an error, this is not essential
        # for testing streaming functionality
        print("Checking server version (errors are expected and can be ignored)...")
        try:
            version = command({'get_version': 0}, s)
            print(f"Server version response: {version}")
        except Exception as e:
            print(f"Version check failed, but we can continue: {e}")
        
        # Enable streaming mode
        print("Enabling streaming mode...")
        stream_resp = command({'enable_streaming': 1}, s)
        print(f"Enable streaming response: {stream_resp}")
        
        # Create a more complex experiment with multiple TX/RX events
        print("Creating experiment with multiple TX/RX events...")
        exp = ex.Experiment(lo_freq=5, rx_t=3.125)
        
        # Define experiment events with 3 separate TX pulses and 3 separate RX windows
        exp.add_flodict({
            # Three TX events at different times
            "tx0": (np.array([50, 150, 350, 450, 650, 750]), np.array([0.5, 0, 0.7, 0, 0.9, 0])),
            
            # Three separate RX windows for each channel
            "rx0_en": (np.array([100, 200, 400, 500, 700, 800]), np.array([1, 0, 1, 0, 1, 0])),
            "rx1_en": (np.array([100, 200, 400, 500, 700, 800]), np.array([1, 0, 1, 0, 1, 0]))
        })
        
        # Compile the experiment
        print("Compiling experiment...")
        exp.compile()
        data = exp._machine_code
        print(f"Machine code size: {len(data)} bytes")
        
        # Run streaming sequence
        print("Running streaming sequence...")
        resp = command({'run_seq_stream': data.tobytes()}, s)
        print(f"Run streaming sequence response: {resp}")
        
        # Setup msgpack unpacker for streaming data
        unpacker = msgpack.Unpacker()
        
        # Set socket to non-blocking to check for streaming data
        print("Waiting for streaming data...")
        s.settimeout(0.5)  # 500ms timeout
        
        # Try to receive data for a few seconds - expecting 3 separate streaming packets
        rx_packets_received = 0
        expected_packets = 3  # We expect 3 separate streaming data packets
        packet_indices = []
        start_time = time.time()
        timeout = 10.0  # 10 seconds timeout - increased to ensure we get all packets
        
        while time.time() - start_time < timeout and rx_packets_received < expected_packets:
            try:
                packet_data = s.recv(4096)
                
                if packet_data:
                    print(f"Received {len(packet_data)} bytes of data")
                    
                    # Try to parse the data as msgpack
                    unpacker.feed(packet_data)
                    
                    for packet in unpacker:
                        # Look for streaming data
                        if len(packet) >= 5 and isinstance(packet[4], dict) and 'stream_data' in packet[4]:
                            rx_packets_received += 1
                            packet_idx = packet[1]
                            packet_indices.append(packet_idx)
                            
                            stream_data = packet[4]['stream_data']
                            print(f"Found streaming packet #{rx_packets_received} with index {packet_idx}!")
                            print(f"Stream data keys: {stream_data.keys()}")
                            
                            if 'rx0_i' in stream_data:
                                rx0_i = stream_data['rx0_i']
                                rx0_q = stream_data['rx0_q']
                                print(f"RX0_I: Found {len(rx0_i)} samples")
                                if len(rx0_i) > 0:
                                    print(f"First few samples: {rx0_i[:5]}")
                            
                            print(f"Progress: Received {rx_packets_received}/{expected_packets} streaming packets")
                
                # If we've received all expected packets, break out of the loop
                if rx_packets_received >= expected_packets:
                    print(f"SUCCESS: All {expected_packets} streaming data packets received!")
                    break
                    
            except socket.timeout:
                print(".", end="", flush=True)
            except Exception as e:
                print(f"Error receiving data: {e}")
                traceback.print_exc()
                break
        
        print("")  # New line after dots
        
        if rx_packets_received == 0:
            print("WARNING: No streaming data received within timeout period")
        
        # Disable streaming
        print("Disabling streaming mode...")
        disable_resp = command({'disable_streaming': 1}, s)
        print(f"Disable streaming response: {disable_resp}")
        
        # Close connection
        s.close()
        print("Test completed!")
        
        return rx_packets_received >= expected_packets
        
    except Exception as e:
        print(f"Test failed: {e}")
        traceback.print_exc()
        try:
            s.close()
        except:
            pass
        return False

if __name__ == "__main__":
    print("Running basic MaRCoS streaming test...")
    success = run_basic_streaming_test()
    if success:
        print("\nTEST PASSED: Streaming functionality is working correctly with multiple RX events!")
        sys.exit(0)
    else:
        print("\nTEST FAILED: Streaming functionality is not working correctly or not all RX events were streamed!")
        sys.exit(1)
