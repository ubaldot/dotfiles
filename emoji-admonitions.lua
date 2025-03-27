function BlockQuote(el)
  if #el.content > 0 and el.content[1].t == "Para" then
    local first_para = el.content[1]
    local first_text = pandoc.utils.stringify(first_para)
    local kind = string.match(first_text, "^%[!(%u+)%]")
    if kind then
      -- Remove [!TIP] from content
      first_para.content = pandoc.List()
      table.remove(el.content, 1)

      -- Map to emoji
      local emoji_map = {
        TIP = "💡 Tip:",
        WARNING = "⚠️ Warning:",
        NOTE = "ℹ️ Note:",
        INFO = "ℹ️ Info:",
        CAUTION = "⚡ Caution:",
      }
      local label = emoji_map[kind] or "💬"

      -- Create final block
      table.insert(el.content, 1, pandoc.Para{pandoc.Str(label)})
      return el
    end
  end
end
