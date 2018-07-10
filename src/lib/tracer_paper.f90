    !------------------------------------------------------------------------------
    !        IST/MARETEC, Water Modelling Group, Mohid modelling system
    !------------------------------------------------------------------------------
    !
    ! TITLE         : Mohid Model
    ! PROJECT       : Mohid Lagrangian Tracer
    ! MODULE        : tracer_paper
    ! URL           : http://www.mohid.com
    ! AFFILIATION   : IST/MARETEC, Marine Modelling Group
    ! DATE          : April 2018
    ! REVISION      : Canelas 0.1
    !> @author
    !> Ricardo Birjukovs Canelas
    !
    ! DESCRIPTION:
    !> Module that defines a Lagrangian tracer class for paper modelling and related methods.
    !> The type is defined as a derived type from the pule Lagrangian tracer, and hence inherits all
    !> of it's data and methods
    !------------------------------------------------------------------------------

    module tracer_paper_mod

    use tracer_base_mod
    use common_modules

    implicit none
    private

    type :: paper_par_class               !<Type - parameters of a Lagrangian tracer object representing a paper material
        real(prec) :: density                       !< density of the material
        real(prec) :: degradation_rate              !< degradation rate of the material
        logical    :: particulate                   !< flag to indicate if the material is a particle (false) or a collection of particles (true)
        real(prec) :: size                          !< Size (radius) of the particles (equals to the tracer radius if particulate==false)
    end type

    type :: paper_state_class             !<Type - State variables of a tracer object representing a paper material
        real(prec) :: radius                        !< Tracer radius (m)
        real(prec) :: condition                     !< Material condition (1-0)
        real(prec) :: concentration                !< Particle concentration
    end type

    type, extends(tracer_class) :: paper_class    !<Type - The plastic material Lagrangian tracer class
        type(paper_par_class)   :: mpar     !<To access material parameters
        type(paper_state_class) :: mnow     !<To access material state variables
    contains

    end type

    !Public access vars
    public :: paper_class

    !Public access routines
    public :: paperTracer

    interface paperTracer !> Constructor
        procedure constructor
    end interface

    contains

    !---------------------------------------------------------------------------
    !> @author Ricardo Birjukovs Canelas - MARETEC
    ! Routine Author Name and Affiliation.
    !
    !> @brief
    !> Paper Tracer constructor
    !
    !> @param[in]
    !---------------------------------------------------------------------------
    function constructor(id,id_source,time,pt)
        implicit none
        type(paper_class) :: constructor
        integer, intent(in) :: id
        integer, intent(in) :: id_source
        real(prec_time), intent(in) :: time
        type(vector), intent(in) :: pt

        !use the base class constructor to build the base of our new derived type
        constructor%tracer_class = Tracer(id,id_source,time,pt)
        !now initialize the specific components of this derived type

    
        end function constructor

  end module tracer_paper_mod
