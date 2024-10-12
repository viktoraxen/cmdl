# CMDL
### *Component Description Language*

CMDL is a very simple version of the hardware discriptor language VHDL, written in Ruby. CMDL generates a dataflow graph of binary values connected through one-way AND-, OR-, and NOT-gates. 

Composite components can be created and reused to make creating complex networks easier. See the example below for an example of a network making use of composite components.

<details>
  <summary>4-bit adder</summary>
  <img src = https://github.com/lyktstolpe/cmdl/assets/37225272/9ad4bb56-7071-4b04-8b26-3e1a883bfa53 width = "500" />
</details>

Synchronized components update the values of input signals on the rising edge of a given synchronization-signal. This makes implementing sequential circuits easy. A D-FlipFlop can be implemented like shown in the example below. Another example below shows an Adder component synchronized on a clock signal, and with its output wired as its input, effectively creating a counter.

<details>
  <summary>D-FlipFlop</summary>
  <img src = https://github.com/user-attachments/assets/96592a34-6ac0-4eb9-8e5c-0a3192c03d54 width = "350" />
</details>

<details>
  <summary>4-bit counter</summary>
  <img src = https://github.com/user-attachments/assets/9f63c453-97e4-45eb-bfd3-0d4117d8a5c0 width = "500" />
</details>

When running CMDL with a circuit file as input, an interactive simulation shell opens. Using the above 4-bit counter as input yields the following simulation interface:

<details>
  <summary>Simulation interface</summary>
  <img src = https://github.com/user-attachments/assets/f061c97a-f11d-440a-9712-a332a9e68784 width = "500" />
</details>

Changing the value of the clock signal to `1`, using the input `clk <= 1`, updates the circuits values, and displays the new state of the circuit, with the affected values highlighted: 

<details>
  <summary>Incremented counter</summary>
  <img src = https://github.com/user-attachments/assets/b2c55f20-6d1d-41d1-a10f-21360ea45079 width = "500" />
</details>

Using the flags and options available when running CMDL, more information about the circuits state can be printed after each simulation update. In the example a print depth was specified to include the first sub-level of components, specifically using the flag `--deep-network-print` and option `--print-depth 1`.

<details>
  <summary>Extended circuit view</summary>
  <img src = https://github.com/user-attachments/assets/08a8be7a-eb54-4852-9557-967906b91c6f width = "500" />
</details>

Adding the flag `--full-network-print` shows also the internal wires of the networks, which can be used for seeing the internal workings of, for example, a 2-bit multiplexer:

<details>
  <summary>2-bit multiplexer</summary>
  <img src = https://github.com/user-attachments/assets/76ffaffc-55b1-4900-83e7-ff44152650ae width = "500" />
</details>

<details>
  <summary>2-bit multiplexer full circuit view</summary>
  <img src = https://github.com/user-attachments/assets/b435a797-f0b9-4d33-abea-cccd162e9f97 width = "500" />
</details>

A tree-sitter parser for CMDL is available [here.](https://github.com/lyktstolpe/tree-sitter-cmdl)

A detailed description of CMDLs features and how to use it might be coming.
