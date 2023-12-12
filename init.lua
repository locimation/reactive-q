(function()

  local Q = {
    listeners = {},
    eventhandlers = {},
    functions = {}
  };

  local function Control(control)
    return setmetatable({}, {
      __index = function(_, k)

        if(k == 'Value' or k == 'String' or k == 'Boolean') then

          local parent = debug.getinfo(2, 'f');
          local reactive = parent and parent.func and Q.functions[parent.func];

          if reactive then
    
            local listeners = Q.listeners;
    
            -- If this control hasn't been used before
            if not listeners[control] then
    
              -- Create a new table for its listeners
              listeners[control] = {};
    
              -- Store its current event handler (if any)
              Q.eventhandlers[control] = control.EventHandler;
    
              -- Take over its event handler
              control.EventHandler = function()
                for fn in pairs(listeners[control] or {}) do fn(); end;
                local eventhandler = Q.eventhandlers[control];
                if(eventhandler) then eventhandler(control); end;
              end;
              
            end
    
            -- Add this function as a listener to this control
            listeners[control][parent.func] = true;
    
          end;

          return control[k];
          
        elseif(k == 'EventHandler') then
          return Q.eventhandlers[control];
        end

      end,
      __newindex = function(_,k,v)

        if(k == 'String' or k == 'Value' or k == 'Boolean') then
          control[k] = v;
          local listeners = Q.listeners;
          if listeners[control] then
            for fn in pairs(listeners[control]) do fn(); end 
          end
        elseif(k == 'EventHandler') then
          Q.eventhandlers[control] = v;
        end

      end
    })
  end;

  local function wrapControls(real_controls_table)
    return setmetatable({
      tbl = real_controls_table
    }, {
      __index = function(t,k) 
  
        local control_or_table = rawget(t, 'tbl')[k];
        if not control_or_table then return; end;
  
        if(type(control_or_table) == 'table') then
          return setmetatable({}, { __index = function(_, i)
            return Control(control_or_table[i])
          end})
        else
          return Control(control_or_table);
        end;
   
      end
    });
  end;
  
  -- Wrap local controls
  Controls = wrapControls(Controls);

  -- Wrap named components API
  local new_component = Component.New;
  Component.New = function(name)
    return wrapControls(new_component(name));
  end;  

  -- Prevent GC of "Q" table.
  _G._reactive_q_data = Q;

  -- Expose "q" API
  _G.q = function(fn)
    Q.functions[fn] = true;
    fn();
  end;

end)();