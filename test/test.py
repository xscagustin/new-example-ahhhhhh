# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    # assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
    # Reset the design
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # Define some functions for capturing lines & frames

    async def check_line(expected_vsync):
        for i in range(H_TOTAL):
            hsync = int(dut.uo_out.value[7])
            vsync = int(dut.uo_out.value[3])
            assert hsync == (0 if H_SYNC_START <= i < H_SYNC_END else 1), "Unexpected hsync pattern"
            assert vsync == expected_vsync, "Unexpected vsync pattern"
            await ClockCycles(dut.clk, 1)

    async def capture_line(framebuffer, offset):
        for i in range(H_TOTAL):
            hsync = int(dut.uo_out.value[7])
            vsync = int(dut.uo_out.value[3])
            assert hsync == (0 if H_SYNC_START <= i < H_SYNC_END else 1), "Unexpected hsync pattern"
            assert vsync == 1, "Unexpected vsync pattern"
            if i < H_DISPLAY:
                framebuffer[offset+3*i:offset+3*i+3] = palette[int(dut.uo_out.value)]
            await ClockCycles(dut.clk, 1)

    async def skip_frame(frame_num):
        dut._log.info(f"Skipping frame {frame_num}")
        await ClockCycles(dut.clk, H_TOTAL*V_TOTAL)

    async def capture_frame(frame_num, check_sync=True):
        framebuffer = bytearray(V_DISPLAY*H_DISPLAY*3)
        for j in range(V_DISPLAY):
            dut._log.info(f"Frame {frame_num}, line {j} (display)")
            line = await capture_line(framebuffer, 3*j*H_DISPLAY)
        if check_sync:
            for j in range(j, j+V_FRONT):
                dut._log.info(f"Frame {frame_num}, line {j} (front porch)")
                await check_line(1)
            for j in range(j, j+V_SYNC):
                dut._log.info(f"Frame {frame_num}, line {j} (sync pulse)")
                await check_line(0)
            for j in range(j, j+V_BACK):
                dut._log.info(f"Frame {frame_num}, line {j} (back porch)")
                await check_line(1)
        else:
            dut._log.info(f"Frame {frame_num}, skipping non-display lines")
            await ClockCycles(dut.clk, H_TOTAL*(V_TOTAL-V_DISPLAY))
        frame = Image.frombytes('RGB', (H_DISPLAY, V_DISPLAY), bytes(framebuffer))
        return frame

    # Start capturing

    os.makedirs("output", exist_ok=True)

    for i in range(CAPTURE_FRAMES):
        frame = await capture_frame(i)
        frame.save(f"output/frame{i}.png")


@cocotb.test()
async def compare_reference(dut):

    for img in glob.glob("output/frame*.png"):
        basename = img.removeprefix("output/")
        dut._log.info(f"Comparing {basename} to reference image")
        frame = Image.open(img)
        ref = Image.open(f"reference/{basename}")
        diff = ImageChops.difference(frame, ref)
        if diff.getbbox() is not None:
            diff.save(f"output/diff_{basename}")
            assert False, f"Rendered {basename} differs from reference image"
