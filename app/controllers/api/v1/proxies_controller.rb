module Api
  module V1
    class ProxiesController < ApplicationController
      before_action :set_proxy, only: [:show, :update, :destroy]

      # GET /api/v1/proxies
      def index
        @proxies = if params[:status].present?
                     Proxy.where(status: params[:status])
                   else
                     Proxy.all
                   end

        render json: {
          count: @proxies.count,
          proxies: @proxies.as_json(except: [:_id, :created_at, :updated_at])
        }
      end

      # GET /api/v1/proxies/:id
      def show
        render json: @proxy.as_json(except: [:_id, :created_at, :updated_at])
      end

      # POST /api/v1/proxies
      def create
        @proxy = Proxy.new(proxy_params)

        if @proxy.save
          # Immediately check the newly added proxy
          ProxyHealthCheckService.check_proxy(@proxy)
          @proxy.reload

          render json: {
            message: 'Proxy added successfully',
            proxy: @proxy.as_json(except: [:_id, :created_at, :updated_at])
          }, status: :created
        else
          render json: {
            message: 'Failed to add proxy',
            errors: @proxy.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/proxies/:id
      def update
        if @proxy.update(proxy_params)
          render json: {
            message: 'Proxy updated successfully',
            proxy: @proxy.as_json(except: [:_id, :created_at, :updated_at])
          }
        else
          render json: {
            message: 'Failed to update proxy',
            errors: @proxy.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/proxies/:id
      def destroy
        @proxy.destroy
        render json: { message: 'Proxy deleted successfully' }
      end

      # GET /api/v1/proxy/best
      def best
        @proxy = Proxy.best_available

        if @proxy
          render json: {
            message: 'Best available proxy',
            proxy: @proxy.as_json(except: [:_id, :created_at, :updated_at])
          }
        else
          render json: {
            message: 'No healthy proxies available',
            proxy: nil
          }, status: :not_found
        end
      end

      # POST /api/v1/proxy/check-all
      def check_all
        total = Proxy.count

        if total.zero?
          render json: {
            message: 'No proxies to check',
            checked: 0
          }
          return
        end

        # Run health checks in background
        Thread.new do
          ProxyHealthCheckService.check_all_proxies
        end

        render json: {
          message: 'Health check initiated for all proxies',
          total_proxies: total
        }
      end

      private

      def set_proxy
        @proxy = Proxy.find(params[:id])
      rescue Mongoid::Errors::DocumentNotFound
        render json: { message: 'Proxy not found' }, status: :not_found
      end

      def proxy_params
        params.require(:proxy).permit(:ip, :port, :status)
      end
    end
  end
end
