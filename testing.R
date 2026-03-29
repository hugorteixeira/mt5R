devtools::load_all()

symbol <- "CCMK26"

options(timeout = 6000)

# se você mudou a porta no EA, ajuste aqui
MT5.ChangeDoorSocket(23456)

cat("Ping:", MT5.Ping(TRUE), "\n")
cat("Versoes batem:", MT5.CheckVersion(), "\n")
print(MT5.ServerTime())

# garante o símbolo no Market Watch
MT5.MarketwatchAdd(symbol)

cat("\n--- Tick de cotacao (melhor teste para tempo real) ---\n")
ticks_info <- MT5.GetTicks(symbol, iRows = 10, sType = "info")
print(ticks_info)

cat("\n--- Tick bruto (todos) ---\n")
ticks_all <- MT5.GetTicks(symbol, iRows = 10, sType = "all")
print(ticks_all)

cat("\n--- Tick de trade / tape ---\n")
ticks_trade <- MT5.GetTicks(symbol, iRows = 10, sType = "trade")
print(ticks_trade)

cat("\n--- Times & Sales ---\n")
tsales <- MT5.GetTimesSales(symbol, iRows = 10)
print(tsales)

buf <- data.frame()

for (i in 1:60) {
  x <- MT5.GetTicks(symbol, iRows = 5, sType = "info")
  buf <- rbind(buf, x)
  buf <- unique(buf)
  cat("iter", i, "ticks_unicos", nrow(buf), "\n")
}

print(tail(buf, 20))

ticks_full <- MT5.DownloadTicksFull(
  sSymbol = symbol,
  sType = "trade",
  iChunk = 2000,
  sFile = paste0(symbol, "_ticks_full.csv"),
  bShowProgress = TRUE
)

str(ticks_full)
tail(ticks_full)

buf <- data.frame()

on_ticks <- function(df_new) {
  buf <<- rbind(buf, df_new)

  # aqui voce pluga sua lib de grafico
  # exemplo:
  # meu_grafico_update(df_new)
}

live_ticks <- MT5.StreamTicksLive(
  sSymbols = c("EURUSD", "GBPUSD"),
  sType    = "all",
  iRows    = 1000,
  fSleep   = 0.25,
  iSeconds = Inf,
  FUN      = on_ticks,
  bPrint   = TRUE
)
