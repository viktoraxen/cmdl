# CMDL
### *Component Description Language*

CMDL is a very simple version of VHDL. CMDL generates a dataflow graph of binary values connected through one-way AND-, OR-, and NOT-gates. 

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

A tree-sitter parser for CMDL is available [here.](https://github.com/lyktstolpe/tree-sitter-cmdl)

A detailed description of CMDLs features and how to use it might be coming.
