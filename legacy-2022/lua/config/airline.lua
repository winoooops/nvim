local status_ok, airline = pcall(require, 'airline')

if not status_ok then
  return 
end

airline.setup({
  airline_theme = 'murmur',
  airline_powerline_fonts = 1
})
