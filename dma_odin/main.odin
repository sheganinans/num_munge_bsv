package dma_odin

import "core:flags"
import "core:fmt"
import "core:mem"
import "core:os"

Mode :: enum {
  Read,
  Write,
}

Options :: struct {
  write: bool `usage:"write the hello.txt test file."`,
}

main :: proc() {
  when ODIN_DEBUG {
    tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, context.allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)
    defer for _, v in tracking_allocator.allocation_map {fmt.printfln("%v: Leaked %v bytes.", v.location, v.size)}
    defer for b in tracking_allocator.bad_free_array {fmt.printfln("Bad free at: %v", b.location)}}

  opt: Options
  flags.parse_or_exit(&opt, os.args, .Odin)

  mode := Mode.Write if opt.write else Mode.Read
  address: i64 = 0x0000_0000

  n := 1024 //0x4000_0000
  dev_name := "/dev/xdma0_c2h_0" if mode == .Read else "/dev/xdma0_h2c_0"
  file_name := "./hello.out.txt" if mode == .Read else "./hello.txt"

  f_flags := os.O_RDONLY if mode == .Write else (os.O_WRONLY | os.O_CREATE | os.O_TRUNC)
  f_mode := 0o000 if mode == .Write else 0o666
  file_p, o1_err := os.open(file_name, f_flags, f_mode)
  if o1_err != nil {fmt.printfln("os.open %s: %v", file_name, o1_err);return}

  d_flags := os.O_WRONLY if mode == .Write else os.O_RDONLY
  dev_fd, o2_err := os.open(dev_name, d_flags)
  if o2_err != nil {fmt.printfln("os.open %s: %v", dev_name, o2_err);return}

  switch mode {
  case .Write:
    fs, fs_err := os.file_size(file_p)
    if fs_err != nil {fmt.printfln("os.file_size %s: %v", file_name, fs_err);return}
    buf := make([]u8, fs)
    defer delete(buf)
    r_err := os_read(file_p, buf)
    if r_err != nil {fmt.printfln("os_read %s: %v", file_name, r_err);return}
    dma_write(dev_fd, address, buf)
  case .Read:
    r_buf, r_err := dma_read(dev_fd, address, n)
    defer delete(r_buf)
    if r_err != nil {fmt.printfln("dma_read %s: %v", dev_name, r_err);return}
    w_err := os_write(file_p, r_buf)
    if w_err != nil {fmt.printfln("os_write %s: %v", file_name, w_err);return}}}

dma_read :: proc(fd: os.Handle, addr: i64, n: int) -> (buf: []u8, err: DMA_Error = nil) {
  os_seek(fd, addr) or_return
  buf = make([]u8, n)
  os_read(fd, buf) or_return
  return}

dma_write :: proc(fd: os.Handle, addr: i64, buf: []u8) -> (err: DMA_Error = nil) {
  os_seek(fd, addr) or_return
  os_write(fd, buf) or_return
  return}

SeekFail :: struct {
  exp:       i64,
  seeked_to: i64,
}
SizeMismatch :: struct {
  exp:   int,
  given: int,
}
DMA_Error :: union {
  os.Error,
  SeekFail,
  SizeMismatch,
}

os_seek :: proc(fd: os.Handle, addr: i64) -> (err: DMA_Error = nil) {
  seeked := os.seek(fd, addr, 0) or_return
  if seeked != addr {err = SeekFail {
      exp       = addr,
      seeked_to = seeked,
    };return}
  return}

os_read :: proc(fd: os.Handle, buf: []u8) -> (err: DMA_Error = nil) {
  tr := os.read(fd, buf) or_return
  if tr != len(buf) {err = SizeMismatch {
      exp   = len(buf),
      given = tr,
    };return}
  return}

os_write :: proc(fd: os.Handle, buf: []u8) -> (err: DMA_Error = nil) {
  wr := os.write(fd, buf) or_return
  if wr != len(buf) {err = SizeMismatch {
      exp   = len(buf),
      given = wr,
    };return}
  return}
