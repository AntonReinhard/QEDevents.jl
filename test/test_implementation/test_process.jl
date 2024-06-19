"""
    TestProcess(rng,incoming_particles,outgoing_particles)

"""
struct TestProcess{IP<:Tuple,OP<:Tuple} <: AbstractProcessDefinition
    incoming_particles::IP
    outgoing_particles::OP
end

function TestProcess(rng::AbstractRNG, N_in::Int, N_out::Int)
    in_particles = rand(rng, PARTICLE_SET, N_in)
    out_particles = rand(rng, PARTICLE_SET, N_out)
    return TestProcess(in_particles, out_particles)
end

QEDprocesses.incoming_particles(proc::TestProcess) = proc.incoming_particles
QEDprocesses.outgoing_particles(proc::TestProcess) = proc.outgoing_particles

function QEDprocesses.in_phase_space_dimension(proc::TestProcess, ::TestModel)
    return number_incoming_particles(proc) * 4
end
function QEDprocesses.out_phase_space_dimension(proc::TestProcess, ::TestModel)
    return number_outgoing_particles(proc) * 4
end

# dummy phase space definition + failing phase space definition
struct TestPhasespaceDef <: AbstractPhasespaceDefinition end
struct TestPhasespaceDef_FAIL <: AbstractPhasespaceDefinition end

# dummy implementation of the process interface

function QEDprocesses._incident_flux(in_psp::InPhaseSpacePoint{<:TestProcess,<:TestModel})
    return _groundtruth_incident_flux(momenta(in_psp, Incoming()))
end

function QEDprocesses._averaging_norm(proc::TestProcess)
    return _groundtruth_averaging_norm(proc)
end

function QEDprocesses._matrix_element(psp::PhaseSpacePoint{<:TestProcess,TestModel})
    in_ps = momenta(psp, Incoming())
    out_ps = momenta(psp, Outgoing())
    return _groundtruth_matrix_element(in_ps, out_ps)
end

function QEDprocesses._is_in_phasespace(psp::PhaseSpacePoint{<:TestProcess,TestModel})
    in_ps = momenta(psp, Incoming())
    out_ps = momenta(psp, Outgoing())
    return _groundtruth_is_in_phasespace(in_ps, out_ps)
end

function QEDprocesses._phase_space_factor(
    psp::PhaseSpacePoint{<:TestProcess,TestModel,TestPhasespaceDef}
)
    in_ps = momenta(psp, Incoming())
    out_ps = momenta(psp, Outgoing())
    return _groundtruth_phase_space_factor(in_ps, out_ps)
end

function QEDprocesses._generate_incoming_momenta(
    proc::TestProcess,
    model::TestModel,
    phase_space_def::TestPhasespaceDef,
    in_phase_space::NTuple{N,T},
) where {N,T<:Real}
    return _groundtruth_generate_momenta(in_phase_space)
end

function QEDprocesses._generate_outgoing_momenta(
    proc::TestProcess,
    model::TestModel,
    phase_space_def::TestPhasespaceDef,
    out_phase_space::NTuple{N,T},
) where {N,T<:Real}
    return _groundtruth_generate_momenta(out_phase_space)
end

function QEDprocesses._total_probability(
    in_psp::InPhaseSpacePoint{<:TestProcess,<:TestModel,<:TestPhasespaceDef}
)
    return _groundtruth_total_probability(momenta(in_psp, QEDbase.Incoming()))
end