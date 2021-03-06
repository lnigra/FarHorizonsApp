class PointsController < ApplicationController
  before_action :set_point, only: [:show, :edit, :update, :destroy]

  # GET /points
  # GET /points.json
  def index
    @points = Point.all
  end

  # GET /points/1
  # GET /points/1.json
  def show
  end

  # GET /points/new
  def new
    @point = Point.new
  end

  # GET /points/1/edit
  def edit
  end

  # POST /points
  # POST /points.json
  def create
    @point = Point.new(point_params)

    respond_to do |format|
      if @point.save
        update_source_point
        if add_point_to_track
          format.html { redirect_to @point, notice: 'Point was successfully added to a track.' }
          format.json { render action: 'show', status: :created, location: @point }
        else
          @point.destroy #Don't retain if not part of an active mission track
          format.html { redirect_to @point, notice: 'No track, point not created.' }
          format.json { render json: @point.errors, status: :unprocessable_entity }
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @point.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /points/1
  # PATCH/PUT /points/1.json
  def update
    respond_to do |format|
      if @point.set(point_params)
        format.html { redirect_to @point, notice: 'Point was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @point.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /points/1
  # DELETE /points/1.json
  def destroy
    @point.destroy
    respond_to do |format|
      format.html { redirect_to points_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_point
      @point = Point.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def point_params
      params.require(:point).permit(:time, :x, :y, :z, :vg, :vx, :vy, :vz, :source_id, :host_id)
    end
    
    def update_source_point
      source = LocationDevice.find( @point.source_id )
      source ||= Beacon.find( @point.source_id )
      source.point.set( point_params )
    end
    
    def add_point_to_track
      host = ChaseVehicle.find( @point.host_id )
      host ||= Platform.find( @point.host_id )
      mission = host.mission
      if mission.start && !mission.actual_end
        if host.class.to_s == "Platform"
          track = host.sky_tracks.select { |x|
            x.source_id == @point.source_id
          }.first
          track ||= SkyTrack.create( :source_id => @point.source_id.to_s,
                                      :platform => host )
          track.add_point( @point )
          track.save
          return track
        elsif host.class.to_s == "ChaseVehicle"
          track = host.ground_track
          track ||= GroundTrack.create( 
              :source_id => @point.source_id.to_s,
              :chase_vehicle => host )
          track.add_point( @point )
          track.save
          return track
        else
          return nil
        end
      else
        return nil
      end
    end
    
  end
