    !------------------------------------------------------------------------------
    !        IST/MARETEC, Water Modelling Group, Mohid modelling system
    !------------------------------------------------------------------------------
    !
    ! TITLE         : Mohid Model
    ! PROJECT       : Mohid Lagrangian Tracer
    ! MODULE        : emitter
    ! URL           : http://www.mohid.com
    ! AFFILIATION   : IST/MARETEC, Marine Modelling Group
    ! DATE          : April 2018
    ! REVISION      : Canelas 0.1
    !> @author
    !> Ricardo Birjukovs Canelas
    !
    ! DESCRIPTION:
    !> Module that defines an emitter class and related methods. This module is
    !> responsible for building a potential tracer list based on the availble
    !> sources and calling their initializers.
    !------------------------------------------------------------------------------

    module emitter_mod

    use common_modules
    use sources_mod
    use tracers_mod
    use tracer_array_mod
    use sources_array_mod    

    implicit none
    private

    type :: emitter_class
        integer :: id
        integer :: emitted
        integer :: emittable
    contains
    procedure :: initialize => initializeEmitter
    procedure :: addSource
    procedure :: removeSource
    procedure :: emitt
    procedure :: tracerMaker
    !procedure :: activecheck
    end type

    !Public access vars
    public :: emitter_class

    contains
    
    !---------------------------------------------------------------------------
    !> @author Ricardo Birjukovs Canelas - MARETEC
    ! Routine Author Name and Affiliation.
    !
    !> @brief
    !> method that initializes an emmiter class object. Sets default values
    !
    !> @param[in] self
    !---------------------------------------------------------------------------
    subroutine initializeEmitter(self, id)
    implicit none
    class(emitter_class), intent(inout) :: self
    integer, intent(in) :: id
    self%id = id
    self%emitted = 0
    self%emittable = 0
    end subroutine initializeEmitter
    
    !---------------------------------------------------------------------------
    !> @author Ricardo Birjukovs Canelas - MARETEC
    ! Routine Author Name and Affiliation.
    !
    !> @brief
    !> method to compute the total emittable particles per source and allocate 
    !> that space in the Blocks Tracer array
    !
    !> @param[in] self, src
    !---------------------------------------------------------------------------
    subroutine addSource(self, src)
    implicit none
    class(emitter_class), intent(inout) :: self
    class(source_class),intent(in) :: src
    self%emittable = self%emittable + src%stencil%total_np
    end subroutine addSource
    
    !---------------------------------------------------------------------------
    !> @author Ricardo Birjukovs Canelas - MARETEC
    ! Routine Author Name and Affiliation.
    !
    !> @brief
    !> method to remove from the total emittable particles count a Source
    !
    !> @param[in] self, src
    !---------------------------------------------------------------------------
    subroutine removeSource(self, src)
    implicit none
    class(emitter_class), intent(inout) :: self
    class(source_class),intent(in) :: src
    self%emittable = self%emittable - src%stencil%total_np
    end subroutine removeSource
    
    !---------------------------------------------------------------------------
    !> @author Ricardo Birjukovs Canelas - MARETEC
    ! Routine Author Name and Affiliation.
    !
    !> @brief
    !> method that emitts the Tracers, based on the Sources on this Block Emitter
    !> this method returns a resized Tracer array if needed to the corresponding
    !> Block
    !
    !> @param[in] self, src, trc
    !---------------------------------------------------------------------------
    subroutine emitt(self, src, trcarr)
    implicit none
    class(emitter_class), intent(inout) :: self !> the Emmiter from the Block where the Source is
    class(source_class), intent(inout)  :: src  !>the Source that will emitt new Tracers
    class(TracerArray), intent(inout)   :: trcarr  !>the Tracer array from the Block where the Source is
    integer err, i
    type(string) :: outext, temp(2)
    integer :: allocstride = 3
    class(*), allocatable :: newtrc

    if (self%emittable <= 0) then
        !nothing to do as we have no Sources or no emittable Tracers
        temp(1) = self%id
        temp(2) = src%par%id
        outext='-->Source '//temp(2)//' trying to emitt Tracers from an exausted Emitter '//temp(1)
        call Log%put(outext,.false.)
    else
        !check if the Block Tracer Array has enough free places for this emission
        if (src%stencil%np > (trcarr%getLength() - trcarr%lastActive)) then
            call trcarr%resize(trcarr%getLength() + allocstride*src%stencil%np, initvalue = dummyTracer) !resizing the Block Tracer array to accomodate more emissions
        end if
        !there is space to emmitt the Tracers
        do i=1, src%stencil%np
            self%emitted = self%emitted + 1 
            self%emittable = self%emittable - 1
            trcarr%lastActive = trcarr%lastActive + 1 !will need to change to paralelize
            trcarr%numActive = trcarr%numActive + 1
            call self%tracerMaker(newtrc, src, i)
            call trcarr%put(trcarr%lastActive, newtrc)
        end do
    endif

    end subroutine
    
    
    !---------------------------------------------------------------------------
    !> @author Ricardo Birjukovs Canelas - MARETEC
    ! Routine Author Name and Affiliation.
    !
    !> @brief
    !> method that calls the corresponding Tracer constructor, depending on the
    !> requested type from the emitting Source
    !
    !> @param[in] sself, trc, src, p
    !---------------------------------------------------------------------------
    subroutine tracerMaker(self, trc, src, p)
    implicit none
    class(emitter_class), intent(in) :: self
    class(*), allocatable, intent(out) :: trc
    class(source_class), intent(inout) :: src
    integer, intent(in) :: p
    type(string) :: outext, temp
    
    select case (src%par%property_type%chars())
    case ('base')
        trc = Tracer(1, src%par%id, Globals%SimTime, src%stencil%ptlist(p))
    case ('paper')
        trc = paperTracer(1, src%par%id, Globals%SimTime, src%stencil%ptlist(p))
    case ('plastic')
        trc = Tracer(1, src%par%id, Globals%SimTime, src%stencil%ptlist(p))
        case default
        outext='[Emitter::tracerMaker]: unexpected type for Tracer object: '//src%par%property_type
        call Log%put(outext)
        stop
    end select
    
    end subroutine tracerMaker
    

  end module emitter_mod
