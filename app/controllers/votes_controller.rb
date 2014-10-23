class VotesController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :update, :destroy]
  before_action :correct_user,   only: [:update, :destroy]

  def new
    @new_comment = Comment.find(vote_params[:comment_id])
    if @new_comment.user_id == current_user.id
      flash[:danger] = "Vous croyez vraiment qu'on aller vous laissez voter pour votre propre commentaire"
      redirect_to reference_path(@new_comment.reference_id)
    else
      @current_vote = Vote.where({user_id: current_user.id, reference_id: vote_params[:reference_id], field: vote_params[:field], value: vote_params[:value]}).first
      if @current_vote
        @current_comment = @current_vote.comment
      end
      @vote = Vote.new()
    end
  end

  def create
    if params[:update]
      comment = Comment.find(vote_params[:comment_id])
      if comment.user_id == current_user.id
        flash[:danger] = "Vous croyez vraiment qu'on aller vous laissez voter pour votre propre commentaire"
        redirect_to reference_path(comment.reference_id)
      else
        @my_vote = Vote.where({user_id: current_user.id, reference_id: vote_params[:reference_id], field: vote_params[:field], value: vote_params[:value]}).first
        if vote_params[:value] == "1"
          Comment.decrement_counter( :votes_plus, @my_vote.comment_id)
          Comment.decrement_counter( :rank, @my_vote.comment_id)
          Comment.increment_counter( :votes_plus,vote_params[:comment_id])
          Comment.increment_counter( :rank,vote_params[:comment_id])
        elsif vote_params[:value] == "0"
          Comment.decrement_counter(:votes_minus, @my_vote.comment_id)
          Comment.increment_counter(:rank, @my_vote.comment_id)
          Comment.increment_counter(:votes_minus, vote_params[:comment_id])
          Comment.decrement_counter(:rank, vote_params[:comment_id])
        end
        most = Comment.where(reference_id: vote_params[:reference_id], field: vote_params[:field]).order(rank: :desc).first
        if most.reference.field_id( vote_params[:field] ) != most.id
          most.reference.displayed_comment( most )
        end
        if @my_vote.update( {comment_id: vote_params[:comment_id]})
          flash[:success] = "Vote enregistré"
          redirect_to controller: 'references', action: 'show', id: vote_params[:reference_id]
        else
          render 'static_pages/home'
        end
      end
    else
      @vote = Vote.new({user_id: current_user.id,
                      reference_id: vote_params[:reference_id], timeline_id: vote_params[:timeline_id],
                     comment_id: vote_params[:comment_id], value: vote_params[:value], field: vote_params[:field]})
        if @vote.save
          flash[:success] = "Vote enregistré"
          redirect_to controller: 'references', action: 'show', id: vote_params[:reference_id]
        else
          render 'static_pages/home'
        end
    end
  end

  def destroy
  end

  private

  def vote_params
    params.require(:vote).permit(:timeline_id, :reference_id, :comment_id, :value, :field)
  end
end
