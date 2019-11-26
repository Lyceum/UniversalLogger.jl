module UniversalLogger

using PushVectors
using Logging: SimpleLogger, BelowMinLevel, AbstractLogger, AboveMaxLevel, with_logger
import Logging


export ULogger, with_logger, finish!


const KeyType = Union{String, Symbol}


struct ULogger <: AbstractLogger
    log::Dict{KeyType,Dict{KeyType, PushVector}}
    lock::ReentrantLock
end
ULogger() = ULogger(Dict{KeyType, Dict{KeyType, PushVector}}(), ReentrantLock())

Base.empty!(ul::ULogger) = (empty!(ul.log); ul)

Base.get(ul::ULogger) = ul.log

Base.push!(ul::ULogger, tag::KeyType, data::AbstractDict) = _push!(ul, tag, data)
Base.push!(ul::ULogger, tag::KeyType, data::Pair...) = _push!(ul, tag, data)
Base.push!(ul::ULogger, tag::KeyType, data::NamedTuple) = _push!(ul, tag, pairs(data))
function _push!(ul::ULogger, tag::KeyType, data)
    lock(ul.lock)
    tagdict = haskey(ul.log, tag) ? ul.log[tag] : ul.log[tag] = Dict{KeyType, PushVector}()
    for (k, v) in data
        _addentry!(tagdict, k, v)
    end
    unlock(ul.lock)
    ul
end

function _addentry!(tagdict, k, v)
    if haskey(tagdict, k)
        entry = tagdict[k]
    else
        entry = tagdict[k] = PushVector{typeof(v)}()
    end
    v = isbits(v) ? v : deepcopy(v)
    push!(entry, v)
end

Base.getindex(ul::ULogger, tag::KeyType) = ul.log[tag]
Base.getindex(ul::ULogger, tag::KeyType, k::KeyType) = ul.log[tag][k]

function PushVectors.finish!(ul::ULogger)
    finished = Dict{KeyType,Dict{KeyType, Vector}}()
    for (tag, data) in pairs(ul.log)
        tagdict = finished[tag] = Dict{KeyType, Vector}()
        for (k, v) in pairs(data)
            tagdict[k] = finish!(v)
        end
    end
    finished
end

function Logging.handle_message(
    ul::ULogger,
    level,
    message,
    _module,
    group,
    id,
    file,
    line;
    kwargs...,
)
    !isempty(kwargs) && push!(ul, message, kwargs)
    ul
end

Logging.shouldlog(::ULogger, arg...) = true
Logging.min_enabled_level(::ULogger) = BelowMinLevel
Logging.catch_exceptions(::ULogger) = false

end # module
